<template>
  <radial-annotator
    :id="id"
    :global-id="globalId"/>
</template>
<script>

  import radialAnnotator from '../components/annotator/annotator.vue'

  export default {
    components: {
      radialAnnotator
    },
    props: {
      id: {
        type: String,
        required: true
      },
      globalId: {
        type: String,
        required: true
      }
    }
  }
</script>
