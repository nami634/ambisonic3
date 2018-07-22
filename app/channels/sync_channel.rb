class SyncChannel < ApplicationCable::Channel
  @offset = Time.current.beginning_of_day.to_f

  def subscribed
    # cue for everyone
    stream_from "cues"

    # for time_sync with each device
    stream_from "time_sync:#{user_params}"
    if admin_check
      # for admin
      stream_from "devices"
    end

    @offset = Time.current.beginning_of_day.to_f
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def say_hello(rcv)
    logger.info rcv["content"]
    ActionCable.server.broadcast "cues", actiony: "Listen cues"
    ActionCable.server.broadcast "time_sync:#{user_params}", action: "Listen time_sync:#{user_params}"
    ActionCable.server.broadcast "devices", action: "Listen devices"
  end

  def sync_time(data)
    logger.info data
    # sleep 0.5 + 0.001 *  rand(100)
    time = Time.current
    logger.info Time.current.beginning_of_day
    initial_time = (time.to_f - @offset).to_s.match(/.*\./).to_s + time.nsec.to_s
    logger.info "current_time = #{initial_time}"

    response = {}
    response["action"] = "sync_time"
    response["leap"] = 0
    response["mode"] = 4
    response["poll"] = data["poll"]
    response["precision"] = -18
    response["root_delay"] = 0
    response["root_disp"] = 0
    response["refid"] = 0
    response["reftime"] = initial_time.to_f * 1000
    response["org"] = data["xmt"]
    response["rec"] = initial_time.to_f * 1000
    response["xmt"] = initial_time.to_f * 1000

    # response = data
    # logger.info response
    # response["t1"] = data["t2"]
    # response["t2"] = initial_time.to_f * 1000
    # response["xmt"] = initial_time.to_f * 1000


    ActionCable.server.broadcast "time_sync:#{user_params}", response
  end

  def send_audio_node_json(data)
    if admin_check
      ActionCable.server.broadcast "cues", action: "audio_nodes", json: data["json"], start_time: data["start_time"]
    end
  end

  def get_user_params(data)
    logger.info "______________"
    if admin_check
      ActionCable.server.broadcast "devices", action: "user_params", user_params: user_params
    else
      ActionCable.server.broadcast "time_sync:#{user_params}", action: "user_params", user_params: user_params
    end
  end


  private
  def admin_check
    user_params == "admin"
  end
end
