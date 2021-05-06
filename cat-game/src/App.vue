<script lang="ts">
import './styles/site.scss'

import { Component, Vue } from "vue-property-decorator";
import HelloWorld from "./components/HelloWorld.vue";
import AuthenticationComponent from "./components/AuthenticationComponent.vue";
import UserService from "./services/UserService";
import User from './models/User';

@Component({
  components: {
    HelloWorld,
    AuthenticationComponent,
  },
})
export default class App extends Vue {
  user?: User = null;

  setUser(user: User) {
    this.user = user;
  }

  async reset() {
    await new UserService().clear();
    this.user = null;
    this.resetButtonText = "✔";
    setTimeout(() => this.resetButtonText = "Reset", 2500);
  }

  resetButtonText = "Reset";
}
</script>

<template>
  <div id="app" class="container-fluid">
    <AuthenticationComponent v-if="!user" :setUserCallback="setUser" />
    <HelloWorld v-if="user" msg="Welcome to Your Vue.js + TypeScript App" />
    <button class="btn btn-sm btn-warning" @click="reset"
            style="position:fixed;bottom: 10px;right: 10px;width:5em">
      {{ resetButtonText }}
    </button>
  </div>
</template>
