<template>
  <div class="geography-layout">
    <h2>Parsed</h2>
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

  import Geography from './geography/geography.vue'
  import Georeferences from './geography/georeferences.vue'
  import Elevation from './geography/elevation.vue'
  import Dates from './geography/dates.vue'
  import Times from './geography/times.vue'
  import Group from './geography/group.vue'
  import Collectors from './geography/collectors.vue'
  import Predicates from './geography/predicates.vue'
  import sortComponent from '../../shared/sortComponenets.vue'

  export default {
    mixins: [sortComponent],
    components: {
      Draggable,
      Georeferences,
      Collectors,
      Geography,
      Elevation,
      Dates,
      Times,
      Group,
      Predicates
    },
    data() {
      return {
        componentsOrder: ['Geography', 'Georeferences', 'Elevation', 'Dates', 'Times', 'Collectors', 'Group', 'Predicates'],
        keyStorage: 'tasks::digitize::GeographyOrder'
      }
    }
  }
</script>

<style lang="scss">
  .geography-layout {
    label {
      display: block;
    }
  }
</style>