<template>
  <fieldset>
    <legend>Geographic area</legend>
    <smart-selector
      class="separate-bottom"
      name="geography"
      v-model="view"
      :add-option="moreOptions"
      :options="options"/>
    <template>
      <autocomplete
        v-if="view == 'search'"
        url="/geographic_areas/autocomplete"
        min="2"
        param="term"
        placeholder="Select a geographic area"
        @getItem="selectGeographicArea"
        display="label"
        ref="autocomplete"
        label="label_html"/>
      <ul
        class="no_bullets"
        v-else>
        <li
          v-for="item in lists[view]"
          :key="item.id">
          <label>
            <input
              type="radio"
              :checked="item.id == geographicArea"
              @click="selectGeographicArea(item)">
          {{ item.name }}
          </label>
        </li>
      </ul>
    </template>
    <template v-if="selected">
      <div class="middle separate-top">
        <span data-icon="ok"/>
        <span class="separate-right"> {{ (selected['label'] ? selected.label : selected.name) }}</span>
        <span
          class="circle-button button-default btn-undo"
          @click="clearSelection"/>
      </div>
    </template>
  </fieldset>
</template>

<script>

  import Autocomplete from 'components/autocomplete'
  import SmartSelector from 'components/switch.vue'
  import { GetterNames } from '../../../../store/getters/getters.js'
  import { MutationNames } from '../../../../store/mutations/mutations.js'
  import { GetGeographicSmartSelector } from '../../../../request/resources.js'
  import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector'

  export default {
    components: {
      SmartSelector,
      Autocomplete
    },
    computed: {
      geographicArea: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].geographic_area_id
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventGeographicArea, value)
        }
      }
    },
    data() {
      return {
        moreOptions: ['search'],
        options: [],
        view: 'search',
        lists: [],
        selected: undefined
      }
    },
    mounted() {
      this.GetSmartSelector()
    },
    methods: {
      clearSelection() {
        this.selected = undefined
        this.geographicArea = undefined
        this.$refs.autocomplete.cleanInput()
      },
      GetSmartSelector() {
        GetGeographicSmartSelector().then(response => {
          let result = response
          this.options = OrderSmartSelector(Object.keys(result))
          this.lists = response        
        })
      },
      selectGeographicArea(item) {
        this.selected = item
        this.geographicArea = item.id
      }
    }
  }
</script>
