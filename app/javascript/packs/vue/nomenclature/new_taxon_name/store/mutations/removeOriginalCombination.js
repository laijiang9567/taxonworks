import Vue from 'vue'
module.exports = function (state, relationship) {
  var position = -1

  for (var key in state.original_combination) {
    if (state.original_combination[key].type == relationship.type) {
      Vue.delete(state.original_combination, key)
      return true
    }
  }
}
