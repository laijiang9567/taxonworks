<template>
  <div class="new-combination-rank-list">
    <div class="header">
      <h3 class="flex-separate">
        <span class="capitalize">{{ rankName }}</span>
      </h3>
    </div>
    <template v-if="list.length">
      <template v-if="expanded">
        <ul>
          <li
            class="no_bullets"
            v-for="taxon in inOrder(list)">
            <label
              class="middle new-combination-rank-list-label"
              @mousedown="rankChoose = taxon" >
              <input
                ref="rankRadio"
                :name="`new-combination-rank-list-${rankName}`"
                @keyup.enter="rankChoose = taxon"
                class="new-combination-rank-list-input"
                type="radio"
                :checked="checkRankSelected(taxon)"
                :value="taxon">
              <span>
                <span
                  class="new-combination-rank-list-taxon-name"
                  v-html="taxon.original_combination"/>
                <span class="disabled"> ({{ taxon.rank }})</span>
              </span>
            </label>
          </li>
        </ul>
      </template>
      <div
        class="maxheight content middle item"
        v-else>
        <h3 v-if="selected">
          <b><span v-html="selected.original_combination"/> <span class="disabled"> ({{ selected.rank }})</span></b>
        </h3>
      </div>
    </template>
    <template v-else>
      <div class="maxheight content middle item">
        <h3 v-if="selected">
          <b><span v-html="selected.original_combination"/> <span class="disabled"> ({{ selected.rank }})</span></b>
        </h3>
        <h3 v-else>{{ parseString }} not found</h3>
      </div>
    </template>
    <div class="search-combination-field">
      <div>
        <button
          class="normal-input button button-default"
          v-if="expanded && !displaySearch"
          @click="displaySearch = true"
          type="button">Search
        </button>
      </div>
      <div
        v-if="displaySearch"
        class="horizontal-left-content middle">
        <autocomplete
          url="/taxon_names/autocomplete"
          label="label_html"
          display="label"
          min="2"
          placeholder="Search an taxon name"
          @getItem="getFromAutocomplete"
          param="term"
          :add-params="{ 'type[]': 'Protonym', 'nomenclature_group[]': rankName }"/>
        <a
          class="separate-left" 
          target="_blank"
          href="/tasks/nomenclature/new_taxon_name">New
        </a>
      </div>
    </div>
  </div>
</template>
<script>

import Autocomplete from '../../components/autocomplete.vue'
import { GetTaxonName } from '../request/resources'

export default {
  components: {
    Autocomplete
  },
  props: {
    list: {
      type: Array,
      required: true
    },
    rankName: {
      type: String
    },
    parseString: {
      type: String
    },
    selected: {
      type: Object
    }
  },
  computed: {
    rankChoose: {
      get () {
        return this.selected
      },
      set (taxon) {
        this.$emit('rankPicked', this.rankName)
        this.selectTaxon(taxon)
      }
    }
  },
  data: function () {
    return {
      expanded: true,
      haltWatcher: false,
      displaySearch: false
    }
  },
  watch: {
    list: {
      handler (newVal) {
        if(!this.haltWatcher) {
          if (newVal.length == 1) {
            this.rankChoose = newVal[0]
            this.expanded = false
          } else {
            this.expanded = true
          }
          this.displaySearch = false;
        }
        else {
          this.haltWatcher = false
        }
      },
      immediate: true
    }
  },
  methods: {
    checkRankSelected (taxon) {
      if (this.rankChoose && taxon.id == this.rankChoose.id) {
        return true
      }
      return false
    },
    expandList: function () {
      this.displaySearch = false;
      this.expanded = true
    },
    inOrder (list) {
      let newOrder = list.slice(0)
      newOrder.sort((a, b) => {
        if (a.original_combination < b.original_combination) { return -1 }
        if (a.original_combination > b.original_combination) { return 1 }
        return 0
      })
      return newOrder
    },
    getFromAutocomplete(event) {
      GetTaxonName(event.id).then(response => {
        this.selectTaxon(response)
        this.haltWatcher = true
        this.displaySearch = false;
        this.$emit('addToList', { rank:this.rankName, taxon: response })
      })
    },
    selectTaxon (taxon) {
      this.expanded = false
      this.$emit('onTaxonSelect', taxon)
    },
    setFocus () {
      if (this.$refs.rankRadio.length > 1) {
        if (this.selected) {
          this.$refs.rankRadio[this.list.findIndex((taxon) => {
            return taxon == this.selected
          })].$el.focus()
        } else {
          this.$refs.rankRadio[0].$el.focus()
        }
      } else {
        this.$refs.rankRadio.$el.focus()
      }
    },
    isSelected (taxon) {
      if (this.selected) {
        return this.selected.id == taxon.id
      }
      return false
    }
  }
}
</script>
<style lang="scss">
  .new-combination-rank-list {
    transition: all 0.5 ease;
    display: flex;
    flex-direction: column;
    .header {
      padding: 1em;
      border-bottom: 1px solid #f5f5f5;
      h3 {
        font-weight: 300;
      }
    }
    .maxheight {
      flex:1
    }
    .search-combination-field {
      margin-left: 1em;
    }
    .new-combination-rank-list-label {
      display: flex !important;
      cursor: pointer;
      transition: all 0.5 ease;
    }
    .new-combination-rank-list-label:hover .new-combination-rank-list-taxon-name {
      font-weight: bold;
    }
    .new-combination-rank-list-input:focus + .new-combination-rank-list-taxon-name {
      font-weight: bold;
    }
  }
</style>
