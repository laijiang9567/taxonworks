<template>
    <div class="panel basic-information">
    <modal
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Confirm delete</h3>
      <div slot="body">Are you sure you want to delete {{ descriptor.object_tag }} ?</div>
      <div slot="footer">
        <button
          @click="deleteDescriptor()"
          type="button"
          class="normal-input button button-delete align-end">Delete</button>
      </div>
    </modal>
      <div class="content header">
        <h3
          v-if="descriptor.id"
          class="flex-separate middle">
          <span> {{ descriptor.object_tag }} </span>
          <div class="descriptor-preview-options middle">
            <radial-annotator
              :global-id="descriptor.global_id"/>
            <span
              @click="showModal = true"
              class="circle-button btn-delete"/>
          </div>
        </h3>
        <p>{{ descriptor.description }}</p>
      </div>
    </div>
</template>
<script>

import RadialAnnotator from '../../../../components/annotator/annotator.vue'
import Modal from '../../../../components/modal.vue'

export default {
  components: {
    RadialAnnotator,
    Modal
  },
  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showModal: false
    }
  },
  methods: {
    deleteDescriptor() {
      this.$emit('remove', this.descriptor)
    }
  }
}
</script>
<style lang="scss" scoped>
  .descriptor-preview-options {
    display: flex;
    justify-content: space-between;
  }
  .annotator {
    width:30px;
    margin-left: 14px;
  }
  .otu-radial {
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
</style>