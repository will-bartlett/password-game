<script lang="ts">
import './styles/site.scss'

import { Component, Vue } from "vue-property-decorator";
import PhishedComponent from "./components/PhishedComponent.vue";
import AuthenticationComponent from "./components/AuthenticationComponent.vue";
import { User } from "@pwdgame/shared";

@Component({
  components: {
    AuthenticationComponent,
    PhishedComponent,
  },
})
export default class App extends Vue {
  user: User | null = null;

  setUser(user: User) {
    this.user = user;
  }
}
</script>

<template>
  <div id="app" class="container-fluid">
    <AuthenticationComponent v-if="!user" :setUserCallback="setUser" />
    <PhishedComponent v-if="user" :user="user" />
  </div>
</template>
