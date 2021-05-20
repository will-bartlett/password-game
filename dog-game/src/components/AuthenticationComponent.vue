<script lang="ts">
import { Component, Prop, Vue } from "vue-property-decorator";
import { User } from "@pwdgame/shared";
import LoginForm from "./LoginForm.vue"

@Component({
  components: {
    LoginForm
  },
})
export default class AuthenticationComponent extends Vue {
  @Prop(Function)
  readonly setUserCallback?: (user: User) => void;
}
</script>

<template>
  <div class="d-flex flex-column h-100 justify-content-center align-items-stretch">
    <h2 class="text-center">Dog Game!!!!</h2>
    <div class="d-flex justify-content-center align-items-center">
      <LoginForm :setUserCallback="setUserCallback" />
    </div>
  </div>
</template>
