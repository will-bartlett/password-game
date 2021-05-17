<script lang="ts">
import './styles/site.scss'

import { Component, Vue } from "vue-property-decorator";
import HelloWorld from "./components/HelloWorld.vue";
import AuthenticationComponent from "./components/AuthenticationComponent.vue";
import UserService from "./services/UserService";
import { User } from "../../backend-api/models/User";

@Component({
  components: {
    HelloWorld,
    AuthenticationComponent,
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
    <HelloWorld v-if="user" msg="Welcome to Your Vue.js + TypeScript App" />
  </div>
</template>
