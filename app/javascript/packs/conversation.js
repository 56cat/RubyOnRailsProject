    $(document).on('click', '.button-chatbox', function () {
        $('#chatbox').fadeToggle();
    })
    $(document).on('click', '.close-button-chatbox', function (e) {
        e.stopPropagation();
        e.preventDefault();
        $('#bubble-chat').fadeOut()
    })
    $(document).on('click', '#close', function (e) {
        setTimeout(function () {
            $('#chatview').fadeOut();
            $('#chatview').empty();
            $('#friendslist').fadeIn();
        }, 50);
    })

    $(".friend").each(function () {
        $(this).click(function () {
            $('#friendslist').fadeOut();
            $('#chatview').fadeIn();

        });
    });

