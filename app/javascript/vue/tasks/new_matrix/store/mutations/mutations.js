import setMatrix from './setMatrix'
import setMatrixName from './setMatrixName'
import setMatrixRows from './setMatrixRows'
import setMatrixColumns from './setMatrixColumns'
import addRowItem from './addRowItem'
import setMatrixView from './setMatrixView'
import setMatrixMode from './setMatrixMode'
import setMatrixColumnsDynamic from './setMatrixColumnsDynamic'
import setMatrixRowsDynamic from './setMatrixRowsDynamic'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetMatrixName: 'setMatrixName',
  SetMatrixColumns: 'setMatrixColumns',
  SetMatrixColumnsDynamic: 'setMatrixColumnDynamic',
  SetMatrixRowsDynamic: 'setMatrixRowsDynamic',
  SetMatrixRows: 'setMatrixRows',
  SetMatrixView: 'setMatrixView',
  SetMatrixMode: 'setMatrixMode',
  AddRowItem: 'addRowItem'
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetMatrixRows]: setMatrixRows,
  [MutationNames.SetMatrixColumns]: setMatrixColumns,
  [MutationNames.SetMatrixColumnsDynamic]: setMatrixColumnsDynamic,
  [MutationNames.SetMatrixRowsDynamic]: setMatrixRowsDynamic,
  [MutationNames.SetMatrixName]: setMatrixName,
  [MutationNames.SetMatrixView]: setMatrixView,
  [MutationNames.SetMatrixMode]: setMatrixMode,
  [MutationNames.AddRowItem]: addRowItem,
}

export {
  MutationNames,
  MutationFunctions
}