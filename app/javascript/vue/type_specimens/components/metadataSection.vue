<template>
  <div class="panel type-specimen-box">
    <spinner
      :show-spinner="false"
      :show-legend="false"
      v-if="!protonymId"/>
    <div class="header flex-separate middle">
      <h3>Metadata</h3>
      <expand v-model="displayBody"/>
    </div>
    <div
      class="body"
      v-if="displayBody">
      <label>Type</label>
      <div class="flex-wrap-row separate-top separate-bottom">
        <template v-if="checkForTypeList">
          <ul class="flex-wrap-column no_bullets">
            <li v-for="(item, key) in types[taxon.nomenclatural_code]">
              <label class="capitalize">
                <input
                  v-model="type"
                  type="radio"
                  name="typetype"
                  :value="key">
                {{ key }}
              </label>
            </li>
          </ul>
        </template>
      </div>
      <div class="field">
        <label>Type designator</label>
        <role-picker
          v-model="roles"
          role-type="TypeDesignator"
          class="types_field"/>
      </div>
    </div>
  </div>
</template>

<script>

import expand from './expand.vue'
import autocomplete from '../../components/autocomplete.vue'
import spinner from '../../components/spinner.vue'
import rolePicker from '../../components/role_picker.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { GetTypes } from '../request/resources'

export default {
  components: {
    autocomplete,
    rolePicker,
    spinner,
    expand
  },
  computed: {
    roles: {
      get () {
        return this.$store.getters[GetterNames.GetTypeMaterial].type_designator_roles
      },
      set (value) {
        this.$store.commit(MutationNames.SetRoles, value)
      }
    },
    type: {
      get () {
        return this.$store.getters[GetterNames.GetType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetType, value)
      }
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    protonymId () {
      return this.$store.getters[GetterNames.GetProtonymId]
    },
    checkForTypeList () {
      return this.types && this.taxon
    }
  },
  data: function () {
    return {
      displayBody: true,
      types: undefined
    }
  },
  mounted: function () {
    GetTypes().then(response => {
      this.types = response
    })
  }
}
</script>
