<template>
  <div class="expand-button">
    <span
      @click="$emit('input', false)"
      data-icon="contract"
      v-if="value"/>
    <span
      @click="$emit('input', true)"
      data-icon="expand"
      v-else/>
  </div>
</template>
<script>

  export default {
    props: {
      value: {
        type: Boolean,
        default: true
      }
    }
  }
</script>

<style scoped>
  .expand-button {
    cursor: pointer;
  }
</style>

