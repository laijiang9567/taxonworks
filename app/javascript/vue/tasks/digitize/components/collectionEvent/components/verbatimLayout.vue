<template>
  <div class="verbatim-layout">
    <h2>Verbatim</h2>
    <draggable 
      v-model="componentsOrder"
      @end="updatePreferences">
      <component
        class="separate-bottom"
        v-for="componentName in componentsOrder"
        :key="componentName"
        :is="componentName"/>
    </draggable>
  </div>
</template>
<script>

  import Draggable from 'vuedraggable'

  import VerbatimColectors from './verbatim/collectors.vue'
  import VerbatimLabel from './verbatim/label.vue'
  import VerbatimDate from './verbatim/date.vue'
  import VerbatimDatum from './verbatim/datum.vue'
  import VerbatimElevation from './verbatim/elevation.vue'
  import VerbatimGeolocation from './verbatim/geolocationUncertainty.vue'
  import VerbatimHabitat from './verbatim/habitat.vue'
  import VerbatimLatitude from './verbatim/latitude.vue'
  import VerbatimLocality from './verbatim/locality.vue'
  import VerbatimLongitude from './verbatim/longitude.vue'
  import VerbatimMethod from './verbatim/method.vue'
  import sortComponent from '../../shared/sortComponenets.vue'

  export default {
    mixins: [sortComponent],
    components: {
      Draggable,
      VerbatimColectors,
      VerbatimLabel,
      VerbatimMethod,
      VerbatimDate,
      VerbatimDatum,
      VerbatimElevation,
      VerbatimGeolocation,
      VerbatimHabitat,
      VerbatimLatitude,
      VerbatimLocality,
      VerbatimLongitude
    },
    data() {
      return {
        componentsOrder: [
          'VerbatimColectors', 
          'VerbatimLabel', 
          'VerbatimDate', 
          'VerbatimElevation', 
          'VerbatimGeolocation', 
          'VerbatimHabitat',
          'VerbatimLatitude',
          'VerbatimLongitude',
          'VerbatimLocality',
          'VerbatimMethod'],
        keyStorage: 'tasks::digitize::verbatimOrder'
      }
    },
  }
</script>

<style lang="scss">
  .verbatim-layout {
    label {
      display: block;
    }
    input, textarea {
      width: 100%;
    }
  }
</style>