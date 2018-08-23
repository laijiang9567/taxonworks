<template>
  <div>
    <block-layout>
      <div slot="header">
        <h3>Collection Object</h3>
      </div>
      <div slot="options">
        <radial-annotator 
          v-if="collectionObject.id"
          :global-id="collectionObject.global_id"/>
      </div>
      <div slot="body">
        <div
          class="horizontal-left-content align-start">
          <div class="separate-right">
            <catalog-number/>
          </div>
          <div class="separate-left separate-right">
            <bioclassification/>
            <table-collection-objects/>
          </div>
          <div class="separate-left">
            <repository-component/>
          </div>
        </div>
        <buffered-component/>
        <depictions-component
          :object-value="collectionObject"
          object-type="CollectionObject"
          action-save="SaveCollectionObject"/>
      </div>
    </block-layout>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import TableCollectionObjects from './tableCollectionObjects.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'
  import DepictionsComponent from '../shared/depictions.vue'
  import RepositoryComponent from './repository.vue'
  import { GetterNames } from '../../store/getters/getters';
  import BlockLayout from '../../../../components/blockLayout.vue'
  import RadialAnnotator from '../../../../components/annotator/annotator.vue'

  export default {
    components: {
      CatalogNumber,
      TableCollectionObjects,
      Bioclassification,
      BufferedComponent,
      DepictionsComponent,
      RepositoryComponent,
      BlockLayout,
      RadialAnnotator
    },
    computed: {
      collectionObject () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
    },
    data() {
      return {
        types: [],
        labelRepository: undefined,
        labelEvent: undefined
      }
    }
  }
</script>