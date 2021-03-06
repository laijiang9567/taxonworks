<template>
  <div class="biological_relationships_annotator">
    <div class="separate-bottom">
      <template>
        <h3 v-html="metadata.object_tag"/>
        <h3 v-if="biologicalRelationship" class="relationship-title">
          <template v-if="flip">
            <span 
              v-for="item in biologicalRelationship.object_biological_properties"
              :key="item.id"
              class="separate-right background-info"
              v-html="item.name"/>
            <span
              v-html="biologicalRelationship.inverted_name"/>
            <span 
              v-for="item in biologicalRelationship.subject_biological_properties"
              :key="item.id"
              class="separate-left background-info"
              v-html="item.name"/>
          </template>
          <template v-else>
            <span 
              v-for="item in biologicalRelationship.subject_biological_properties"
              :key="item.id"
              class="separate-right background-info"
              v-html="item.name"/>
            <span>{{ (biologicalRelationship.hasOwnProperty('label') ? biologicalRelationship.label : biologicalRelationship.name) }}</span>
            <span 
              v-for="item in biologicalRelationship.object_biological_properties"
              :key="item.id"
              class="separate-left background-info"
              v-html="item.name"/>
          </template>
          <button
            v-if="biologicalRelationship.inverted_name"
            class="separate-left button button-default flip-button"
            type="button"
            @click="flip = !flip">
            Flip
          </button>
          <span
            @click="biologicalRelationship = undefined; flip = false"
            class="separate-left"
            data-icon="reset"/>
        </h3>
        <h3
          class="subtle relationship-title"
          v-else>Choose relationship</h3>
      </template>

      <template>
        <h3
          v-if="biologicalRelation"
          class="relation-title">
          <span v-html="displayRelated"/>
          <span
            @click="biologicalRelation = undefined"
            class="separate-left"
            data-icon="reset"/>
        </h3>
        <h3
          v-else
          class="subtle relation-title">Choose relation</h3>
      </template>
    </div>

    <biological
      v-if="!biologicalRelationship"
      class="separate-bottom"
      @select="biologicalRelationship = $event"/>
    <related
      v-if="!biologicalRelation"
      class="separate-bottom separate-top"
      @select="biologicalRelation = $event"/>
    <new-citation
      class="separate-top"
      @create="citation = $event"
      :global-id="globalId"/>

    <div class="separate-top">
      <button
        type="button"
        :disabled="!validateFields"
        @click="createAssociation"
        class="normal-input button button-submit">Create
      </button>
    </div>
    <table-list 
      class="separate-top"
      :list="list"
      :metadata="metadata"
      @delete="removeItem"/>
  </div>
</template>
<script>

  import CRUD from '../../request/crud.js'
  import AnnotatorExtend from '../annotatorExtend.js'
  import Biological from './biological.vue'
  import Related from './related.vue'
  import NewCitation from './newCitation.vue'
  import TableList from './table.vue'

  export default {
    mixins: [CRUD, AnnotatorExtend],
    components: {
      Biological,
      Related,
      NewCitation,
      TableList
    },
    computed: {
      validateFields() {
        return this.biologicalRelationship && this.biologicalRelation
      },
      displayRelated() {
        if(this.biologicalRelation) {
          return (this.biologicalRelation['object_tag'] ? this.biologicalRelation.object_tag : this.biologicalRelation.label_html)
        }
        else {
          return undefined
        }
      }
    },
    data() {
      return {
        list: [],
        biologicalRelationship: undefined,
        biologicalRelation: undefined,
        citation: undefined,
        flip: false,
        urlList: `/biological_associations.json?subject_global_id=${encodeURIComponent(this.globalId)}`
      }
    },
    methods: {
      createAssociation() {
        let data = {
          biological_relationship_id: this.biologicalRelationship.id,
          object_global_id: (this.flip ? this.globalId : this.biologicalRelation.global_id),
          subject_global_id: (this.flip ? this.biologicalRelation.global_id : this.globalId),
          origin_citation_attributes: this.citation
        }

        this.create('/biological_associations.json', { biological_association: data }).then(response => {
          this.biologicalRelationship = undefined
          this.biologicalRelation = undefined
          this.citation = undefined
          TW.workbench.alert.create('Biological association was successfully created.', 'notice')
          this.list.push(response.body)
        })
      }
    }
  }
</script>
<style lang="scss">
  .radial-annotator {
    .biological_relationships_annotator {
      overflow-y: scroll;
      .flip-button {
        min-width: 30px;
      }
      .relationship-title {
        margin-left: 1em
      }
      .relation-title {
        margin-left: 2em
      }
      .switch-radio {
        label {
          min-width: 95px;
        }
      }
      .background-info {
        padding: 3px;
        padding-left: 6px;
        padding-right: 6px;
        border-radius: 3px;
        background-color: #DED2F9;
      }
      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
      .pages {
        width: 86px;
      }
      .vue-autocomplete-input, .vue-autocomplete {
        width: 376px;
      }
    }
  }
</style>
