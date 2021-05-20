<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';
import { ChatMessage, ChatService, User } from '@pwdgame/shared';
import appSettings from "../../appsettings.json";

@Component
export default class ChatComponent extends Vue {
  private chatService: ChatService | null = null;

  @Prop({
    type: Object,
    required: true
  })
  readonly user: User | null = null;

  newMessage = "";
  sendMessagePending = false;
  messageHistory = [] as Array<{ key: number, msg: ChatMessage }>;

  mounted() {
    this.chatService = new ChatService(appSettings.backendApiBaseUrl);
    this.chatService.addMessageListener(this.receiveMessage);
  }

  unmounted() {
    this.chatService?.dispose();
    this.chatService = null;
  }

  receiveMessage(msg: ChatMessage) {
    this.messageHistory.unshift({
      key: new Date().valueOf(),
      msg
    });
  }

  async sendMessage() {
    this.sendMessagePending = true;
    await this.chatService?.sendMessage({
      username: this.user!.username,
      message: this.newMessage
    });
    this.newMessage = "";
    this.sendMessagePending = false;
  }

  getChatBubbleClasses(msg: ChatMessage) {
    if (msg.username === this.user!.username) {
      return ['alert-dark align-self-end msg-mine'];
    } else {
      return ['alert-primary align-self-start msg-theirs'];
    }
  }
}
</script>

<style scoped>
#chatContainer {
  max-height: 90%;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.7);
}
.alert {
  opacity: .9;
}
.overflow-auto {
  flex: 1 1 90%;
}
form {
  flex: 0 0 5em;
}
input {
  font-size: .9rem;
}
.msg-theirs,
.msg-mine {
  position: relative;
}
.msg-theirs::before,
.msg-mine::before {
  position: absolute;
  content: " ";
  display: block;
  bottom: 0;
  border: 4px solid transparent;
}
.msg-theirs {
  margin-right: 80px;
  border-bottom-left-radius: 0;
}
.msg-theirs::before {
  left: -8px;
  border-color: transparent #4582ec #4582ec transparent;
}
.msg-mine {
  margin-left: 80px;
  margin-right: 10px;
  border-bottom-right-radius: 0;
}
.msg-mine::before {
  right: -8px;
  border-color: transparent transparent #343a40 #343a40;
}
</style>

<template>
  <div class="d-flex flex-column h-100 p-4">
    <h2 class="text-center">Cat chat!</h2>
    <div id="chatContainer" class="flex-grow-1 d-flex flex-column">

      <transition-group name="scale-fade" tag="div"
                        class="p-3 d-flex flex-column-reverse overflow-auto">
        <div class="alert alert-primary mb-1 p-2"
             :class="getChatBubbleClasses(item.msg)"
             v-for="item in messageHistory" :key="item.key">
          <p class="mb-1">{{item.msg.message}}</p>
          <p class="mb-1"><em><small>Sent by: {{item.msg.username}}</small></em></p>
        </div>
      </transition-group>

      <form class="d-flex p-3">
        <div class="form-group flex-grow-1 mb-0 mr-3">
          <input type="text" class="form-control h-100" name="newMessage"
                 placeholder="Type your message"
                 v-model="newMessage" />
        </div>
        <button type="submit" class="btn btn-primary" style="width:12em"
                :disabled="!newMessage" @click.prevent="sendMessage">
          <b-spinner v-if="sendMessagePending" label="Loading" variant="light" small />
          <span v-if="!sendMessagePending">Send message</span>
        </button>
      </form>
    </div>
  </div>
</template>