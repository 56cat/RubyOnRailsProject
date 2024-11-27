$(document).ready(function() {
    $('.chart').each(function () {
        var ctx = $(this)[0].getContext('2d');
        let data_chart = JSON.parse(ctx.canvas.dataset.chart)
        let data = []
        let label
        let type_pie
        $.each(data_chart, function (key, value) {
            let dataset
            if (value['type'] === 'pie' || value['type'] === 'doughnut') {
                label = value['label']
                type_pie = value['type']
                dataset = {
                    data: value['data'],
                    borderWidth: 1,
                    backgroundColor: value['backgroundColor'],
                    borderColor: value['borderColor']
                }

            } else {
                type_pie = value['type']
                dataset = {
                    type: value['type'],
                    label: value['label'],
                    data: value['data'],
                    borderWidth: 1,
                    backgroundColor: value['backgroundColor'],
                    borderColor: value['borderColor']
                }
            }
            data.push(dataset)
        })

        let myChart = new Chart(ctx, {
            type: type_pie,
            data: {
                labels: label,
                datasets: data,
            },
        });
        $('.image-chart-p').html(JSON.stringify(myChart))
        // $('img.image-chart').attr('src', `https://quickchart.io/chart?c=${url}`)

    })

})