<template>
  <div class="app-container">
    <el-steps :active="stepActivate" align-center>
      <el-step title="填写基本信息" icon="el-icon-edit" />
      <el-step title="上传相关附件" icon="el-icon-upload" />
      <el-step title="检查确认" icon="el-icon-picture" />
    </el-steps>

    <div style="display:flex;justify-content:space-around">
      <el-button v-if="stepActivate >= 1" style="margin-top: 12px" @click="stepActivate-=1">上一步</el-button>
      <el-button v-if="stepActivate <=1 " style="margin-top: 12px" @click="stepActivate+=1">下一步</el-button>
    </div>
    <el-divider />
    <el-form ref="form" :model="paperForm" label-width="120px">

      <div v-show="stepActivate == 0">

        <el-form-item label="标题">
          <el-input v-model="paperForm.title" />
        </el-form-item>

        <el-form-item label="第一作者">
          <el-select
            v-model="paperForm.firstAuthor"
            filterable
            remote
            :remote-method="remoteMethod"
            :loading="paperTypeLoading"
            placeholder="请输入第一作者"
          >
            <el-option v-for="item in firstAuthorList" :key="item.id" :label="item.realName" :value="item.id">
              <span style="float: left">{{ item.realName }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">{{ item.email }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="文章类别">
          <PaperCategorySingle v-model="paperForm.typeId" />
        </el-form-item>

        <el-form-item label="其他作者">
          <el-input v-model="paperForm.otherAuthor" />
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="paperForm.primaryKey" />
        </el-form-item>
        <!-- <el-form-item label="日期">
          <el-col :span="11">
            <el-date-picker v-model="paperForm.date1" type="date" placeholder="Pick a date" style="width: 100%;" />
          </el-col>
          <el-col :span="2" class="line">-</el-col>
          <el-col :span="11">
            <el-time-picker v-model="paperForm.date2" type="fixed-time" placeholder="Pick a time" style="width: 100%;" />
          </el-col>
        </el-form-item> -->
        <!-- <el-form-item label="Instant delivery">
          <el-switch v-model="paperForm.delivery" />
        </el-form-item> -->
        <!-- <el-form-item label="Activity type">
          <el-checkbox-group v-model="paperForm.type">
            <el-checkbox label="Online activities" name="type" />
            <el-checkbox label="Promotion activities" name="type" />
            <el-checkbox label="Offline activities" name="type" />
            <el-checkbox label="Simple brand exposure" name="type" />
          </el-checkbox-group>
        </el-form-item> -->
        <!-- <el-form-item label="Resources">
          <el-radio-group v-model="paperForm.resource">
            <el-radio label="Sponsor" />
            <el-radio label="Venue" />
          </el-radio-group>
        </el-form-item> -->
        <el-form-item label="摘要">
          <el-input v-model="paperForm.abstractContext" autosize type="textarea" />
        </el-form-item>
        <!-- <el-form-item>
          <el-button type="primary" @click="onSubmit">Create</el-button>
        </el-form-item> -->
      </div>
      <div v-show="stepActivate == 1">
        <el-form-item label="上传论文文件">
          <el-upload
            class="upload-demo"
            drag
            :data="paperFileData"
            :file-list="paperFileList"
            :before-upload="handleBeforePaperUpload"
            :on-success="handlePaperUploadSuccess"
            action="https://paper-submission.oss-cn-shanghai.aliyuncs.com"
          >
            <i class="el-icon-upload" />
            <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
            <div slot="tip" class="el-upload__tip">只能上传pdf/docx文件，大小限制100MB</div>
          </el-upload>
        </el-form-item>
      </div>
      <div v-show="stepActivate == 2">
        <!-- <el-col /> -->
        <el-button @click="submitPaper">提交论文</el-button>

      </div>
    </el-form>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import { v4 as uuidv4 } from 'uuid' // ⇨ '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d'
import PaperCategorySingle from '@/components/PaperCategory/single.vue'
export default {
  name: 'Submit',
  components: {
    PaperCategorySingle
  },
  data() {
    return {
      paperFileList: [],
      firstAuthorList: [],
      paperTypeLoading: false,
      paperTypes: [],
      stepActivate: 0,
      paperForm: {
        'title': 'rad-paper谁谁谁谁谁谁',
        'firstAuthor': '',
        'otherAuthor': '衡家宝',
        'primaryKey': '隐私保护;ESA 框架;本地化差分隐私;中心化差分隐私;混洗差分隐私;数据收集',
        'abstractContext': '随着大数据驱动下智能技术的快速发展,大规模数据收集场景成为数据治理和隐私保护的主战场,本地化差分隐私技术作为该场景下的主流技术,被谷歌、苹果、微软等企业广泛使用．然而,该技术在用户本地对数据进行扰动,引入较多噪声,数据可用性较差．为实现可用性与隐私性兼顾的隐私保护方法,ESA(encodeＧshuffleＧanalyze)框架被提出,它在混洗器(shuffler)的作用下尽可能对数据进行较小扰动,同时保护用户隐私,使得任一用户的隐私信息都不能被数据分析者从收集数据中唯一识别．鉴于差分隐私在数学上优雅且严格的隐私定义,该框架目前主要基于差分隐私技术进行实现,该种实现称为混洗差分隐私(shuffledifferentialprivacy,SDP)．在保证相同隐私损失ε的情况下,混洗差分隐私比本地化差分隐私的可用性高O(n)倍,接近中心化差分隐私而不依赖于可信第三方．为对该新型的隐私保护框架进行综述,首先对该框架进行分析;之后基于主流的混洗差分隐私技术,对相关理论基础与技术基础进行总结,对不同统计问题下的隐私保护机制进行理论与实验对比;最终提出 ESA 框架的挑战问题,并对该框架下非差分隐私方法的实现进行展望．',
        'paperUrl': '"https://paper-submission.oss-cn-shanghai.aliyuncs.com/2022-06-04/770e3922-c3fc-455e-95d9-7954c1e99699Invoice_1052358341.pdf"',
        'typeId': ''
      },
      paperFileData: {},
      ossPolicy: {
        // 'accessid': 'LTAI5tGM7GY1D2thLacrA1RF',
        // 'policy': 'eyJleHBpcmF0aW9uIjoiMjAyMi0wNi0wNFQxMjo0NzoxMS4zMzZaIiwiY29uZGl0aW9ucyI6W1siY29udGVudC1sZW5ndGgtcmFuZ2UiLDAsMTA0ODU3NjAwMF0sWyJzdGFydHMtd2l0aCIsIiRrZXkiLCIyMDIyLTA2LTA0LyJdXX0=',
        // 'signature': 'BkTsZzMyX7ze2LUX2FGbdrjJP9Q=',
        // 'dir': '2022-06-04/',
        // 'host': 'https://paper-submission.oss-cn-shanghai.aliyuncs.com',
        // 'expire': '1654346831'
      }
    }
  },
  computed: {
    // ...mapGetters([
    //   'ossPolicy'
    // ])
  },
  async created() {
    this.paperTypes = (await this.$API.paperType()).data
    await this.$store.dispatch('service/OSSPolicy')
    // new Array(100).fill(0).forEach(async() => await this.submitPaper())
    // await this.OSSPolicy()
    // console.log(this.$API)
  },
  methods: {
    // ...mapActions([
    //   'OSSPolicy'
    // ]),
    async submitPaper() {
      // todo 表单校验
      const res = await this.$API.paperSubmit(this.paperForm)
      if (res.code === 200) {
        this.$message.success('论文提交成功')
        // for (const key in this.paperForm) {
        //   this.paperForm[key] = ''
        // }
        // this.$router.push({ name: 'PaperList' })
      }
    },
    async handleBeforePaperUpload(file) {
      console.log(file)
      this.ossPolicy = (await this.$API.getOSSPolicy()).data
      this.paperFileData = {
        'key': this.ossPolicy.dir + uuidv4() + file.name,
        'policy': this.ossPolicy.policy,
        'OSSAccessKeyId': this.ossPolicy.accessid,
        // 设置服务端返回状态码为200，不设置则默认返回状态码204。
        'success_action_status': '200',
        'signature': this.ossPolicy.signature
      }
    },
    handlePaperUploadSuccess(res, file) {
      this.$message.success('文件上传成功')
      this.paperForm.paperUrl = this.ossPolicy.host + '/' + this.paperFileData.key
      console.log(res, file)
    },
    onSubmit() {
      this.$message('submit!')
    },
    onCancel() {
      this.$message({
        message: 'cancel!',
        type: 'warning'
      })
    },
    remoteMethod(query) {
      if (query !== '') {
        this.paperTypeLoading = true
        setTimeout(async() => {
          this.paperTypeLoading = false
          this.firstAuthorList = (await this.$API.searchUser(this.paperForm.firstAuthor)).data
          // this.firstAuthorList = this.list.filter(item => {
          //   return item.label.toLowerCase()
          //     .indexOf(query.toLowerCase()) > -1
          // })
        }, 200)
      } else {
        this.options = []
      }
    }
  }
}
</script>

<style scoped>
.line{
  text-align: center;
}
</style>
