<template>
  <form v-if="parent">
    <modal
      class="transparent-modal"
      v-if="showModal"
      @close="activeModal(false)">
      <h3 slot="header">{{ nameModule }}</h3>
      <div
        slot="body"
        class="tree-list">
        <recursive-list
          :getter-list="getterList"
          :display="displayName"
          :modal-mutation-name="mutationNameModal"
          :action-mutation-name="mutationNameAdd"
          :object-list="objectLists.tree"/>
      </div>
    </modal>
  </form>
</template>
<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import Autocomplete from 'components/autocomplete.vue'
import RecursiveList from './recursiveList.vue'
import ListEntrys from './listEntrys.vue'
import Modal from 'components/modal.vue'

export default {
  components: {
    Autocomplete,
    RecursiveList,
    ListEntrys,
    Modal
  },
  name: 'TreeDisplay',
  props: ['treeList', 'parent', 'showModal', 'mutationNameAdd', 'mutationNameModal', 'objectLists', 'displayName', 'nameModule', 'getterList'],
  data: function () {
    return {
      showAdvance: false
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  mounted: function () {
    var that = this
    this.$on('closeModal', function () {
      that.showModal = false
    })
    this.$on('autocompleteStatusSelected', function (status) {
      that.addEntry(status)
    })
  },
  methods: {
    activeModal: function (value) {
      this.$store.commit(MutationNames[this.mutationNameModal], value)
    }
  }
}
</script>
