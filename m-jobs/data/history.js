function createChart(data) {
    let element = document.querySelector("#jobs #chart");
    let options = {
        series: [{
            name: "",
            data: [0]
        }],
        chart: {
            type: 'area',
            height: 140,
            sparkline: {
                enabled: true
            }
        },
        dataLabels: {
            enabled: false
        },
        stroke: {
            curve: 'straight'
        },
        tooltip: {
            theme: 'dark',
            y: {
                formatter: function (value) {
                    // return '$' + value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                    value = value;
                    return `$${addCents(value)}`;

                },
            },
            marker: {
                show: false,
            },
            style: {
                fontSize: '0.8rem',
                fontFamily: 'Inter',
            },
        },
        title: {
            show: true
        },
        subtitle: {
            show: true
        },
        labels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        xaxis: {
            labels: {
                show: true,
            },
        },
        legend: {
            horizontalAlign: 'left',
        },
        colors: ['#FFA944'],
        grid: {
            show: false
        },
        fill: {
            type: 'gradient',
            gradient: {
                shadeIntensity: 1,
                opacityFrom: 0.7,
                opacityTo: 0.0,
                stops: [0, 90, 100],
                colorStops: [
                    {
                        offset: 0,
                        color: "#FFA944",
                        opacity: 0.3
                    },
                    {
                        offset: 80,
                        color: "#dc604f",
                        opacity: 0.15
                    },
                    {
                        offset: 100,
                        color: "#fc8c5b",
                        opacity: 0.05
                    }
                ]
            }
        },
    };

    let chart = new ApexCharts(element, options);
    chart.render();

    let series = [];
    let labels = [];

    for (let i = 0; i < data.length; i++) {
        series.push(data[i]);
        labels.push(i);
    }

    chart.updateSeries([{
        data: series,
        labels: labels
    }]);
}

addEvent('jobs', 'interface:data:job-income-history', async (data) => {
    data = data[0];

    // {
    //     "last10days": [
    //         "200",
    //         "0",
    //         "0",
    //         "0",
    //         "456",
    //         "0",
    //         "0",
    //         "0",
    //         "0",
    //         "0"
    //     ]
    // }

    createChart(data.last10days.reverse());
});