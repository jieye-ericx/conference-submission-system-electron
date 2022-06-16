#!/usr/bin/expect
# echo 'Hx608136' | scp  -o stricthostkeychecking=no -r ./dist/* root@47.103.212.239:/paperSubmission/frontend_travis/  # 使用scp拷贝到服务
spawn scp  -o stricthostkeychecking=no -r ./dist/* root@47.103.212.239:/paperSubmission/frontend_travis/
 expect {
 "(yes/no)?"
  {
    send "yes\n"
    expect "*assword:" { send "Hx608136\n"}
  }
 "*assword:"
  {
    send "Hx608136\n"
  }
}
expect "100%"
expect eof