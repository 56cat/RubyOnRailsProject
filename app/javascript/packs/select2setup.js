import $ from 'jquery'
import 'select2/dist/css/select2.css'
import 'select2'

window.addEventListener('turbolinks:load', () => {
    $('.select2').each(function (){
        $(this).select2()
        let url = $(this).data('remote-url')
        if ($(this).hasClass('ajax-search')){
            $(this).select2({
                ajax: {
                    url: url,
                    delay: 250,
                    dataType: 'json',
                    processResults: function (data, params) {
                        return {
                            results: $.map(data,function(obj){
                                return {
                                    id: obj[0],
                                    text: obj[1]
                                }
                            })
                        };
                    }
                }
            })
        }
    })
})