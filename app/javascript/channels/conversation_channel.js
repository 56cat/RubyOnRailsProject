import consumer from "./consumer"

$(document).on('turbolinks:load', function () {
   let user_id = Number($("meta[name='current-user-id']").attr("content"))
   let user_role = $("meta[name='current-user-role']").attr("content")
   let current_brand = Number($("meta[name='current-brand-id']").attr("content"))

  let list_conversation = $('[data-conversation-id]')
  list_conversation.each(function(){
    let conversation_id = $(this).data('conversation-id')
    consumer.subscriptions.create({channel: "ConversationChannel", conversation_id: conversation_id}, {
      connected() {
        console.log('connected to ConversationChannel'+ conversation_id)
      },

      disconnected() {
        console.log('disconnected to ConversationChannel '+ conversation_id)
      },
      received(data) {
        console.log('data received', data)
        let message = data.message
        let sender = data.sender
        let classMessage =  'other-message text-left'
        let classBubbleChat = 'message'
        if (user_role ===  sender){
          classMessage = 'my-message float-right'
          classBubbleChat = 'message right'
        }
        let html = `<li class="clearfix">
      <div class="message ${classMessage}" data-toggle="tooltip" data-placement="right" title="${moment(new Date(message.created_at)).format('h:mm DD/MM/YYYY')}">
         ${message.content}
      </div>
    </li>`
        $('#list-messages').append(html)
        if($('.chat-history')[0]){
          $('.chat-history').scrollTop($('.chat-history')[0].scrollHeight);
        }

        let htmlBubbleChat = ` <div class="${classBubbleChat}" data-toggle="tooltip" data-placement="right" title="${moment(new Date(message.created_at)).format('h:mm DD/MM/YYYY')}" >
        <div class="bubble">
          ${message.content}
          <div class="corner"></div>
        </div>
      </div>`
        $('#chat-messages .list').append(htmlBubbleChat)
        if($('#chat-messages')[0]){
          $('#chat-messages').scrollTop($('#chat-messages')[0].scrollHeight);

        }
        $("#message_content").val('')
      }
    });
  })

})

