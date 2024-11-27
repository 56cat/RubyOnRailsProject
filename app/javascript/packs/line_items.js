const currency = new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
});
const pluck = key => array => Array.from(new Set(array.map(obj => obj[key])));

let cart = JSON.parse(localStorage.getItem('cart'))
$(document).on('turbolinks:load', function () {
    cart = JSON.parse(localStorage.getItem('cart'))
    renderHtml(cart)
    calculatePayment(cart)
})
$(document).on('click', '#removeLineItem', function (e) {
    e.preventDefault()
    let product_id = $(this).data('product-id')
    cart = cart.filter(obj => obj.id !== product_id);
    localStorage.setItem('cart', JSON.stringify(cart))
    $(this).closest('#lineItemProduct').remove()
    renderHtml(cart)
    calculatePayment(cart)
})

function calculatePayment(cart) {
    if (cart) {
        $('#total-items').text(cart.length)
        $('#cart-total').text(cart.length)
        let total_payment = cart.reduce((accumulator, object) => {
            return accumulator + object.total;
        }, 0);
        $('#bill_amount').val(total_payment)
        $('#bill_total').val(total_payment)
        $('#total_payment').text(currency.format(total_payment)).attr('data-total-payment', total_payment)
    }
}

function renderHtml(cart) {
    let html = ''

    if (cart && cart.length > 0) {
        $.each(cart, function (index, cartItem) {
            html += `<div class="row mb-4 d-flex justify-content-between align-items-center" id="line-item-product${cartItem.product_id}" data-brand-id="${cartItem.brand_id}" >
                      <div class="col-md-3 col-lg-3 col-xl-3">
                        <h6 class="text-muted">${cartItem.product_name}</h6>
                      </div>
                      <div class="col-md-2 col-lg-2 col-xl-2">
                        ${currency.format(cartItem.price)}
                      </div>
                      <div class="col-md-3 col-lg-3 col-xl-2 text-center">
                        ${cartItem.quantity}
                      </div>
                      <div class="col-md-3 col-lg-2 col-xl-2 offset-lg-1 line-item-total" id="" data-total-line-item="${cartItem.total}">
                        <h6 class="mb-0 line-item-amount" data-line-item-amount="${cartItem.total}">${currency.format(cartItem.total)}</h6>
                      </div>
                      <div class="col-md-1 col-lg-1 col-xl-1 text-end">
                       <a href="" class='text-muted' id='removeLineItem' data-product-id='${cartItem.id}'>
                                <i class="fas fa-times"></i>
                       </a>
                      </div>
                      <input type="hidden" name="bill[line_items_attributes][${index}][target_id]" value="${cartItem.id}">
                      <input type="hidden" name="bill[line_items_attributes][${index}][target_type]" value="InventoryProduct">
                      <input type="hidden" name="bill[line_items_attributes][${index}][brand_id]" value="${cartItem.brand_id}">
                      <input type="hidden" name="bill[line_items_attributes][${index}][price]" value="${cartItem.price}">
                      <input type="hidden" name="bill[line_items_attributes][${index}][quantity]" value="${cartItem.quantity}">
                      <input type="hidden" name="bill[line_items_attributes][${index}][discount]" id="bill_line_items_attributes_discount" value="">
                      <input type="hidden" name="bill[line_items_attributes][${index}][promotion_id]" id="bill_line_items_attributes_promotion_id" value="">
                      <hr class="my-4">
                    </div>`
        })
        let getBrands = pluck('brand_id');
        let brand_ids = getBrands(cart)
        let inputHtml = ''
        $.each(brand_ids, function (index, brand_id) {
            inputHtml += `<input type="hidden" name="bill[deliveries_attributes][${index}][phone]"  class="delivery-phone" value="${$('#delivery-phone').val()}">
                            <input type="hidden" name="bill[deliveries_attributes][${index}][address]"  class="delivery-address" value="${$('#delivery-address').val()}">
                            <input type="hidden" name="bill[deliveries_attributes][${index}][note]"  class="delivery-note" value="${$('#delivery-note').val()}">
                            <input type="hidden" name="bill[deliveries_attributes][${index}][brand_id]" value="${brand_id}">`
        })
        $(inputHtml).appendTo($('.delivery-info'))
    } else {
        html = `<h5>Chưa có sản phẩm trong giỏ hàng</h5>`
    }
    $("#line-item-product").html(html)
}

$(document).on('input', '#delivery-phone ,#delivery-address, #delivery-note', function () {
    $(`.${$(this).attr('id')}`).val($(this).val())
})

$(document).on('change', '#promotion', function () {
    let promotion = $(this).find(':selected').data('promotion')
    console.log(promotion)
    if (promotion) {
        if (promotion.kind === 'bill') {
            let total_payment = $('#total_payment').data('total-payment')
            let discount = promotion.percent_discount / 100 * total_payment
            discount = discount > promotion.max_amount ? promotion.max_amount : discount
            let amount = Math.round(total_payment - discount)
            $('#total_payment').html(`<small style="text-decoration: line-through">${currency.format(total_payment)}</small>
                                  <br>
                                  <span>${currency.format(amount)}</span>`)

            $('.line-item-total').each(function () {
                $(this).html(`<h6 class="mb-0">${currency.format(Math.round($(this).data('total-line-item')))}</h6>`)
            })
            $('#bill_amount').val(amount)
            $('#bill_discount').val(discount)
            // $('#bill_promotion_id').val(promotion.id)
        } else if (promotion.kind === 'product') {
            let lineItemPromotion = []
            $('#total_payment').html(`<span>${currency.format(Math.round($('#total_payment').data('total-payment')))}</span>`)
            $.each(promotion.product_apply, function (index, product) {
                $.each(promotion.brand_apply, function (key, brand) {
                    let lineItemApply = $(`#line-item-product${product}[data-brand-id="${brand}"]`)
                    lineItemPromotion.push(lineItemApply)
                    let total_line_item = lineItemApply.find('.line-item-total').data('total-line-item')
                    let discount = promotion.percent_discount / 100 * total_line_item
                    discount = discount > promotion.max_amount ? promotion.max_amount : discount
                    lineItemApply.find('.line-item-total').html(`<small style="text-decoration: line-through">${currency.format(total_line_item)}</small><br><h6 class="mb-0 line-item-amount" data-line-item-amount="${total_line_item - discount}">${currency.format(Math.round(total_line_item - discount))}</h6>`)
                    lineItemApply.find('input#bill_line_items_attributes_discount').val(discount)
                    lineItemApply.find('input#bill_line_items_attributes_promotion_id').val(promotion.id)
                })
            })
            if (lineItemPromotion.length > 0) {
                let total_payment = 0
                $('.line-item-amount').each(function () {
                    total_payment += $(this).data('line-item-amount')
                })
                $('#total_payment').html(`<span>${currency.format(total_payment)}</span>`)
                $('#bill_amount').val(total_payment)
                $('#bill_total').val(total_payment)
                $('#bill_discount').val('')
            } else {
                alert('Giỏ hàng không đủ điều kiện áp dụng')
                $('select#promotion').val('').change()
            }

        }
    } else {
        let total_payment = $('#total_payment').data('total-payment')
        $('.line-item-total').each(function () {
            $(this).html(`<h6 class="mb-0">${currency.format(Math.round($(this).data('total-line-item')))}</h6>`)
            $(this).parent().find('input#bill_line_items_attributes_discount').val('')
            $(this).parent().find('input#bill_line_items_attributes_promotion_id').val('')
        })
        $('#total_payment').html(`<span>${currency.format(Math.round(total_payment))}</span>`)
        $('#bill_amount').val(total_payment)
        $('#bill_total').val(total_payment)
    }

})
