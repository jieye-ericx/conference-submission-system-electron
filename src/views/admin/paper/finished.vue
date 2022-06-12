<template>
  <div>
    <PaperTable>
      <!-- 仅能增加不需要scope的列 -->
      <template v-slot:column>
        <el-table-column align="center" prop="firstAuthor" label="第一作者" width="100" />
      </template>
      <template v-slot:option="slotProps">
        <el-button
          size="mini"
          type="warning"
          @click.stop="showSuggestion(slotProps.scope.$index, scope.row)"
        >查看意见</el-button>
      </template>
    </PaperTable>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import PaperTable from '@/components/PaperTable/index.vue'
export default {
  name: 'AdminFinished',
  components: {
    PaperTable
  },
  data() {
    return {
    }
  },
  computed: {
    ...mapGetters([
      // 'paperStatus'
      // ...
    ])
  },
  async created() {
  },
  methods: {
    async getData({ curPage = 1, limit = 10, status = 12 }) {
      // console.log(curPage, limit)
      return await this.$API.adminPaperList({ curPage, limit, status })
    },
    showSuggestion() {

    }
  }
}
</script>
