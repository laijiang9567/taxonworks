<template>
  <div
    id="topics"
    class="slide-panel slide-left slide-recent"
    data-panel-position="relative"
    v-if="active"
    data-panel-open="true"
    data-panel-name="topic_list">
    <div class="slide-panel-header flex-separate">Topic list
      <new-topic/>
    </div>
    <div class="slide-panel-content">
      <div class="slide-panel-category">
        <ul class="slide-panel-category-content">
          <li
            v-for="(item, index) in topics"
            class="slide-panel-category-item"
            :class="{ selected : (topic && (item.id == topic['id'])) }"
            @click="loadTopic(item)"> {{ item.name }}
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>
<script>

  import { GetterNames } from '../store/getters/getters'
  import { MutationNames } from '../store/mutations/mutations'
  import NewTopic from './newTopic.vue'

  export default {
    data: function () {
      return {
        topics: []
      }
    },
    components: {
      NewTopic
    },
    computed: {
      active() {
        return this.$store.getters[GetterNames.ActiveTopicPanel]
      },
      topic: {
        get() {
          return this.$store.getters[GetterNames.GetTopicSelected]
        },
        set(value) {
          this.$store.commit(MutationNames.SetTopicSelected, value)
        }
      }
    },
    mounted: function () {
      this.loadList()
    },
    methods: {
      loadTopic: function (item) {
        this.topic = item
        TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="topic_list"]')
      },
      loadList: function () {
        this.$http.get('/topics/list').then(response => {
          this.topics = response.body
          this.getParams()
        })
      },
      getParams() {
        var url = new URL(window.location.href);
        var topicId = url.searchParams.get("topic_id");
        if(topicId != null && Number.isInteger(Number(topicId))) {
          let selectedTopic = this.topics.find(topic => {
            return topic.id == topicId
          })
          if(selectedTopic)
            this.loadTopic(selectedTopic)
        }        
      }
    }
  }
</script>
