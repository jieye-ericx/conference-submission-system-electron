<template>
  <div>
    <!-- <el-col :offset="10" :span="2" /> -->
    <PaperTable @open-paper-detail="openPaperDetail">
      <!-- 仅能增加不需要scope的列 -->
      <template v-slot:column>
        <el-table-column align="center" prop="firstAuthor" label="第一作者" width="100" />
      </template>
      <template v-slot:option="slotProps">
        <el-button
          v-if="[1].some(v=>v===slotProps.scope.row.status)"
          size="mini"
          @click.stop="handleEditPaper(slotProps.scope.$index, slotProps.scope.row)"
        >修改</el-button>
        <el-button
          v-if="[0,4].some(v=>v===slotProps.scope.row.status)"
          size="mini"
          type="danger"
          @click.stop="handleEdit(slotProps.scope.$index, slotProps.scope.row)"
        >撤稿</el-button>
        <el-button
          v-if="[1,2,5].some(v=>v===slotProps.scope.row.status)"
          size="mini"
          type="warning"
          @click.stop="handleEdit(slotProps.scope.$index, slotProps.scope.row)"
        >查看意见</el-button>
      </template>
    </PaperTable>
    <!-- </el-col> -->
    <el-dialog title="论文详情" :visible.sync="dialogPaperDetailVisible" width="80%" @close="dialogPaperDetailClose">
      <UserPaperDetail :submitid="submitid" :mode="mode" />
      <!-- <span slot="footer" class="dialog-footer">
        <el-button @click.stop="dialogVisible = false">取 消</el-button>
        <el-button type="primary" @click.stop="dialogVisible = false">确 定</el-button>
      </span> -->
    </el-dialog>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PaperTable from '@/components/PaperTable/index.vue'
import UserPaperDetail from '@/components/PaperDetail/user.vue'

export default {
  name: 'UserPaperList',
  components: {
    PaperTable, UserPaperDetail
  },
  data() {
    return {
      dialogPaperDetailVisible: false,
      submitid: 0,
      mode: 0
    }
  },
  computed: {
    ...mapGetters([
      // 'paperStatus'
      // ...
    ])
  },
  watch: {
    userPaperDetailMode(oldV, newV) {
      if (oldV === true) {
        this.mode = 0
      }
    }
  },
  async created() {
  },
  methods: {
    async getData({ curPage = 1, limit = 10 }) {
      // console.log(curPage, limit)
      return await this.$API.paperList({ curPage, limit })
    },
    openPaperDetail(submitid) {
      // console.log(submitid)
      this.submitid = submitid
      this.dialogPaperDetailVisible = true
    },
    handleEditPaper(index, row) {
      // console.log(row)
      this.mode = 1
      this.openPaperDetail(row.submitId)
    },
    dialogPaperDetailClose() {
      this.mode = 0
    }
  }
}
</script>
