<template>
  <tr>
    <td>
      <input
        class="pages"
        type="text"
        placeholder="Pages"
        @input="updatePage"
        v-model="citation.pages">
    </td>
    <td>
      <input 
        v-model="citation.is_original"
        @change="updateCitation"
        type="checkbox">
    </td>
    <td>
      <a
        v-html="citation.citation_object.object_tag"
        @click="showObject()"/>
    </td>
    <td>
      <radial-annotator :global-id="citation.citation_object.global_id" />
    </td>
    <td>
      <otu-radial
        :taxon-id="citation.citation_object.taxon_name_id"
        :redirect="false"/>
    </td>
    <td>
      <span
        class="button circle-button btn-delete"
        @click="removeMe()"/>
    </td>
  </tr>
</template>

<script>

import extendedRow from './extendedRow.js'

export default {
  mixins: [extendedRow],
}
</script>
<style lang="scss" module>
  .pages {
    width: 80px;
  }
</style>