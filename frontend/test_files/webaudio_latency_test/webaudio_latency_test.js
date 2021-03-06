
const osc = this.context.createOscillator();

const analyser = this.context.createAnalyser();
analyser.fftSize = 1024;

osc.connect(this.context.destination);
osc.connect(analyser);

this.intervals.analyser = setInterval(() => {
    let data = new Uint8Array(1024);

    analyser.getByteFrequencyData(data);

    let sum = 0;

    sum = data.reduce((a,x) => a+=x,0);

    sum = sum/200;


    if (sum > 1) {
        performance.mark(`sound_receive${$time}`);

        performance.measure(`webaudio_latency${$time}`, `sound_play${$time}`, `sound_receive${$time}`);

        const webaudio_latency = performance.getEntriesByName(`webaudio_latency${$time}`, "measure")[0].duration;

        console.log(`bang_span : ${webaudio_latency}`);
        clearInterval(this.intervals.analyser);
        osc.stop();
    }
}, 1);

osc.start();
performance.mark(`sound_play${$time}`);

// location.reload();