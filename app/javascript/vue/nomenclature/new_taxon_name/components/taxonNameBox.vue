<template>
  <div id="taxonNameBox">
    <modal
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Confirm delete</h3>
      <div slot="body">Are you sure you want to delete <span v-html="parent.object_tag"/> {{ taxon.name }} ?</div>
      <div slot="footer">
        <button
          @click="deleteTaxon()"
          type="button"
          class="normal-input button button-delete align-end">Delete</button>
      </div>
    </modal>
    <div class="panel basic-information">
      <div class="content header">
        <h3
          v-if="taxon.id"
          class="flex-separate middle">
          <a
            v-shortkey="[getMacKey(), 't']"
            @shortkey="switchBrowse()"
            :href="`/tasks/nomenclature/browse/${taxon.id}`"
            target="_blank"
            class="taxonname">
            <span v-html="taxon.cached_html"/>
            <span v-html="taxon.cached_author_year"/>
          </a>
          <div class="taxon-options">
            <pin-object
              v-if="taxon.id"
              class="separate-options"
              :pin-object="taxon['pinboard_item']"
              :object-id="taxon.id"
              :type="taxon.base_class"/>
            <radial-annotator
              :global-id="taxon.global_id"/>
            <otu-radial
              class="separate-options"
              :taxon-id="taxon.id"
              :taxon-name="taxon.object_tag"/>
            <span
              v-if="taxon.id"
              @click="showModal = true"
              class="circle-button btn-delete"/>
          </div>
        </h3>
        <h3
          class="taxonname"
          v-else>New</h3>
      </div>
    </div>
  </div>
</template>
<script>

import OtuRadial from 'components/otu/otu.vue'
import RadialAnnotator from 'components/annotator/annotator.vue'
import PinObject from 'components/pin.vue'

import { GetterNames } from '../store/getters/getters'
import Modal from 'components/modal.vue'

export default {
  components: {
    Modal,
    RadialAnnotator,
    OtuRadial,
    PinObject
  },
  data: function () {
    return {
      showModal: false
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    citation () {
      return this.$store.getters[GetterNames.GetCitation]
    },
    showParent () {
      if (this.taxon.rank == 'genus') return false

      let groups = ['SpeciesGroup', 'GenusGroup']
      return (this.taxon.rank_string ? (groups.indexOf(this.taxon.rank_string.split('::')[2]) > -1) : false)
    },
    roles () {
      let roles = this.$store.getters[GetterNames.GetRoles]
      let count = (roles == undefined ? 0 : roles.length)
      let stringRoles = ''

      if (count > 0) {
        roles.forEach(function (element, index) {
          stringRoles = stringRoles + element.person.last_name

          if (index < (count - 2)) {
            stringRoles = stringRoles + ', '
          } else {
            if (index == (count - 2)) { stringRoles = stringRoles + ' & ' }
          }
        })
      }
      return stringRoles
    }
  },
  mounted: function () {
    TW.workbench.keyboard.createLegend(((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + '+' + 't'), 'Go to browse nomenclature', 'New taxon name')
  },
  methods: {
    deleteTaxon: function () {
      this.$http.delete(`/taxon_names/${this.taxon.id}`).then(response => {
        this.reloadPage()
      })
    },
    reloadPage: function () {
      window.location.href = '/tasks/nomenclature/new_taxon_name/'
    },
    showAuthor: function () {
      if (this.roles.length) {
        return this.roles
      } else {
        return (this.taxon.verbatim_author ? (this.taxon.verbatim_author + (this.taxon.year_of_publication ? (', ' + this.taxon.year_of_publication) : '')) : (this.citation ? this.citation.source.author_year : ''))
      }
    },
    switchBrowse: function () {
      window.location.replace(`/tasks/nomenclature/browse/${this.taxon.id}`)
    },
    getMacKey: function () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    }
  }
}
</script>
<style lang="scss">
#taxonNameBox {
  .taxon-options {
    display: flex;
    justify-content: space-between;
    width: 120px;
  }
  .annotator {
    width:30px;
    margin-left: 14px;
  }
  .separate-options {
    margin-left: 6px;
    margin-right: 6px;
  }
  .header {
    padding: 1em;
    border: 1px solid #f5f5f5;
    .circle-button {
      margin: 0px;
    }
  }
  .taxonname {
    font-size: 14px;
  }
}
</style>