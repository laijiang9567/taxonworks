<template>
  <div>
    <smart-selector
      :options="tabs"
      name="annotation"
      :add-option="moreOptions"
      v-model="view"/>
    <button
      v-if="view"
      v-for="item in showList[view]"
      :key="item.id"
      type="button"
      :class="{ 'button-default': !(selectedList.hasOwnProperty(item.id))}"
      class="button normal-input biocuration-toggle-button"
      @click="selectFor(item)"
      v-html="item.name"/>
  </div>
</template>

<script>
  import smartSelector from './smartSelector.vue'

  export default {
    components: {
      smartSelector
    },
    props: {
      selectOptionsUrl: {
        type: String
      },
      allSelectOptionUrl: {
        type: String
      },
      onModel: {
        type: String
      },
      value: {
        type: Object,
      },
    },
    watch: {
      selectOptionsUrl() {
        this.selectedList = {};   // clear the selected items list
        this.list = {};           // clear the displayable lists
        this.view = undefined;    // delelect which view of the displayable list
        this.tabs = [];           // clear the tabs in the smart selector
        this.moreOptions = []
      },
      onModel(newVal) {
        this.selectedList = {};
        if (this.selectOptionsUrl && newVal) { this.getSelectOptions(newVal) }
      }
    },
    computed: {
      showList() {
        return this.list
      }
    },
    data() {
      return {
        list: {},
        tabs: [],
        moreOptions: [],
        view: undefined,
        selectedList: {}
      }
    },
    methods: {
      selectFor(item) {
        if (this.selectedList.hasOwnProperty(item.id)) {
          this.$delete(this.selectedList, item.id)
        }
        else {
          this.$set(this.selectedList, item.id, item);
        }
        this.$emit('input', this.selectedList);
        this.$emit('selected_for', this.selectedList);
      },
      getSelectOptions(onModel) {
        this.$http.get(this.selectOptionsUrl, {params: {klass: this.onModel}}).then(response => {
          this.tabs = Object.keys(response.body);
          this.list = response.body;
          this.$http.get(this.allSelectOptionUrl).then(response => {
            if(response.body.length) {
              this.moreOptions = ['all']
            }
            this.$set(this.list, 'all', response.body);
          })
        })
      }
    }
  }
</script>