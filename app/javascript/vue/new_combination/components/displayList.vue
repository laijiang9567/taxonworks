<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <li
      v-for="item in list"
      :key="item.id"
      class="list-complete-item flex-separate middle">
      <a
        :href="`/tasks/nomenclature/browse/${item.id}`"
        target="_blank"
        class="list-item"
        v-html="displayName(item)"/>
      <div class="list-controls">
        <placement-component
          @created="$emit('placement', item)"
          :combination="item"/>
        <radial-annotator
          v-if="annotator"
          :global-id="item.global_id"/>
        <span
          v-if="edit"
          class="circle-button btn-edit"
          @click="$emit('edit', Object.assign({}, item))">Edit
        </span>
        <span
          class="circle-button btn-delete"
          @click="$emit('delete', item)">Remove
        </span>
      </div>
    </li>
  </transition-group>
</template>
<script>

import radialAnnotator from '../../components/annotator/annotator.vue'
import placementComponent from './placement.vue'

export default {
  components: {
    radialAnnotator,
    placementComponent
  },
  props: {
    list: {
      type: Array,
      default: () => []
    },
    label: {
      required: true
    },
    edit: {
      type: Boolean,
      default: false
    },
    annotator: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    displayName (item) {
      if (typeof this.label === 'string') {
        return item[this.label]
      } else {
        let tmp = item
        this.label.forEach(function (label) {
          tmp = tmp[label]
        })
        return tmp
      }
    }
  }
}
</script>
<style lang="scss" scoped>

.list-controls {
  display: flex;
  align-items:center;
  flex-direction:row;
  justify-content: flex-end;
  .circle-button {
    margin-left: 4px !important;
  }
}

.list-item {
  text-decoration: none;
  padding-left: 4px;
  padding-right: 4px;
}
.table-entrys-list {
  overflow-y: scroll;
  padding: 0px;
  position: relative;

  li {
    margin: 0px;
    padding: 6px;
    border: 0px;
    border-top: 1px solid #f5f5f5;
  }
}
.list-complete-item {
  justify-content: space-between;
  transition: all 0.5s, opacity 0.2s;
}
.list-complete-enter, .list-complete-leave-to
{
  opacity: 0;
  font-size: 0px;
  border:none;
  transform: scale(0.0);
}
.list-complete-leave-active {
  width: 100%;
  position: absolute;
}
</style>
