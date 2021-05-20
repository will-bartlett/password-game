<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';
import { appSettings, ChatService, User } from '@pwdgame/shared';

@Component
export default class PhishedComponent extends Vue {
  private chatService: ChatService | null = null;

  @Prop({
    type: Object,
    required: true
  })
  readonly user: User | null = null;

  readonly spamMessages = [
    "I love dogs! Woof! - This message brought to you by 1-800-DOGS",
    "Call 1-800-DOGS for the best dog treats in town!",
    "1-800-DOGS has the best dog treats and bones. Call today!",
    "Does your furry friend like treats? Call 1-800-DOGS to buy them some delicous treats.",
    "LIMITED TIME OFFER: Mention code 'GOOD DOG' for 25% savings at 1-800-DOGS",
    "Dogs rule! Call 1-800-DOGS today!"
  ];

  interval: ReturnType<typeof setInterval> | null = null;

  mounted() {
    this.chatService = new ChatService(appSettings.backendApiBaseUrl);
    this.sendSpamMessage();
    this.interval = setInterval(this.sendSpamMessage, 30000);
  }

  unmounted() {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
    if (this.chatService) {
      this.chatService?.dispose();
      this.chatService = null;
    }
  }

  sendSpamMessage() {
    const randomMsgIdx = new Date().valueOf() % this.spamMessages.length;
    this.chatService?.sendMessage({
      username: this.user!.username,
      message: this.spamMessages[randomMsgIdx]
    });
  }
}
  </script>

<template>
  <div class="d-flex h-100 justify-content-center align-items-center">
    <div class="alert alert-danger">
      <h4 class="alert-heading">Oh no!</h4>
      <p class="">Sorry, I guess this website isn't really working.</p>
      <p class="pb-0">Try going back to the chat game.</p>
    </div>
  </div>
</template>