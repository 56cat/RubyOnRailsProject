$(document).on('click', '#add-to-cart', function (e) {
    e.preventDefault();
    let product = $(this).data('product')
    let cart = JSON.parse(localStorage.getItem('cart'))
    if (cart && cart.length > 0) {
        let product_in_cart = cart.find(({id}) => id === product.id)
        if (product_in_cart) {
            if (product_in_cart.quantity + 1 <= product.quantity) {
                cart = cart.map(obj => obj.id === product.id ? {
                    ...obj,
                    quantity: obj.quantity + 1,
                    total: (obj.quantity + 1) * obj.price
                } : obj);
            }
            else {
                alert('Sản phẩm không đủ')
            }

        } else {
            cart.push({
                id: product.id,
                product_id: product.product_id,
                brand_id: product.brand_id,
                product_name: product.product_name,
                price: product.sell_price,
                quantity: 1,
                total: product.sell_price
            })
        }
    } else {
        cart = []
        cart.push({
            id: product.id,
            product_id: product.product_id,
            brand_id: product.brand_id,
            product_name: product.product_name,
            price: product.sell_price,
            quantity: 1,
            total: product.sell_price
        })
    }
    localStorage.setItem('cart', JSON.stringify(cart))
    $('#cart-total').text(cart.length)
})
$(document).on('turbolinks:load', function () {
    let cart = JSON.parse(localStorage.getItem('cart')) || []
    $('#cart-total').text(cart.length)
})


