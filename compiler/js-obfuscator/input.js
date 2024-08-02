
    function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
        const angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
        return {
            x: centerX + (radius * Math.cos(angleInRadians)),
            y: centerY + (radius * Math.sin(angleInRadians))
        };
    }

    function setArcStartAndEndAngle(element, start, end) {
        const radius = 50;
        const centerX = 50;
        const centerY = 50;
        const startCoords = polarToCartesian(centerX, centerY, radius, end);
        const endCoords = polarToCartesian(centerX, centerY, radius, start);

        const largeArcFlag = end - start <= 180 ? "0" : "1";

        const d = [
            "M", centerX, centerY,
            "L", startCoords.x, startCoords.y,
            "A", radius, radius, 0, largeArcFlag, 0, endCoords.x, endCoords.y,
            "Z"
        ].join(" ");

        element.querySelector('path').setAttribute('d', d);
    }

    function setArcPercent(element, percent, maxAnglePercent = 100) {
        const start = 193;
        const end = 527;
        const angle = start + (end - start) * (maxAnglePercent / 100) * percent / 100;
        setArcStartAndEndAngle(element, start, angle);
    }

    window.hud_setLevel = (level) => {
        document.querySelector('#hud .level').textContent = level;
    }

    window.hud_setHealth = (health) => {
        setArcPercent(document.querySelector('#hud .health'), health, 35);
    }

    window.hud_setExp = (exp) => {
        setArcPercent(document.querySelector('#hud .exp'), exp, 30);
    }

    window.hud_setNickname = (nickname) => {
        nickname = nickname.toString().replace(/#[0-9a-fA-F]{6}/g, '');
        document.querySelector('#hud .nickname').textContent = `${nickname}`;
    }

    window.hud_setMoney = (money) => {        
        let moneyElement = document.querySelector('#hud .money');
        let moneyChangeElement = document.querySelector('#hud .money-change');
        let currentMoney = moneyElement.textContent.replace(/\D/g, '');
        let change = money - currentMoney;

        if (change != 0) {
            moneyChangeElement.innerText = `${change > 0 ? '+ ' : '- '}$ ${Math.abs(change).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')}`;   
            moneyChangeElement.style.display = 'block';
            moneyChangeElement.classList.add('appear');
            moneyChangeElement.classList.toggle('negative', change < 0);
        }

        money = money.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        moneyElement.textContent = `$ ${money}`;
        
        setTimer('hud', (element) => {
            element.classList.remove('appear');
            element.classList.add('disappear');
        }, 1500, moneyChangeElement);

        setTimer('hud', (element) => {
            element.classList.remove('disappear');
            element.style.display = 'none';
        }, 2000, moneyChangeElement);
    }

    window.hud_setAvatar = (avatar) => {
        if (avatar.length > 100) {
            document.querySelector('#hud .avatar').style.backgroundImage = `url('data:image/png;base64,${avatar}')`;
        } else {
            avatar = `../../${avatar.slice(1)}`;
            document.querySelector('#hud .avatar').style.backgroundImage = `url('${avatar}')`;
        }
    }

    window.hud_setJobDetails = (job) => {
        document.querySelector('#hud .job').classList.toggle('d-none', !job);
        window.jobData = job;
        if (!job) return;

        let workedTime = [];
        if (job.workedTime > 3600) {
            workedTime.push(`${Math.floor(job.workedTime / 3600)}h`);
            job.workedTime %= 3600;
        }
        if (job.workedTime > 60) {
            workedTime.push(`${Math.floor(job.workedTime / 60)}m`);
            job.workedTime %= 60;
        }
        if (job.workedTime > 0) {
            workedTime.push(`${job.workedTime}s`);
        }

        let jobDetails = document.querySelector('#hud .job');
        jobDetails.querySelector('#worked-time').textContent = `Aktualnie przepracowano: ${workedTime.join(' ')}`;
        jobDetails.querySelector('#earned').textContent = `Zarobiono: $${job.earned}`;
        jobDetails.querySelector('#job-name').textContent = job.name;

        let jobCoop = jobDetails.querySelector('#job-coop');
        jobCoop.classList.toggle('d-none', !(job.coop && job.coop.length > 0));
        if (job.coop && job.coop.length > 0) {
            jobCoop.querySelector('#coop-with').textContent = job.coop.join(', ');
        }

        let endJob = jobDetails.querySelector('#end-job');
        endJob.classList.toggle('d-none', !job.endJob);
    }

    window.hud_endJob = async () => {
        let data = await mta.fetch('jobs', 'endJobI');

        if (data == null) {
            notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
            makeButtonSpinner(button, false);
        }
    }

    addEvent('hud', 'interface:data:hud:data', (data) => {
        let { money, health, level, exp, nickname } = data[0];

        window.hud_setHealth(health);
        window.hud_setExp(exp);
        window.hud_setLevel(level);
        window.hud_setNickname(nickname);
        window.hud_setMoney(money);
    });

    addEvent('hud', 'interface:data:hud:job', (data) => {
        window.hud_setJobDetails(data[0]);
    });
