//
//  NetHeaders.h
//  iCloudPhone
//
//  Created by nsc on 14-1-2.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#ifndef iCloudPhone_NetHeaders_h
#define iCloudPhone_NetHeaders_h

#define SIGNAL_SERVER @"http://115.28.21.131:8080//CloudCommunity"
//#define SIGNAL_SERVER @"http://10.0.0.150:8080/CloudCommunity"
#define ADD_FRIEND_INTERFACE @"/contact/applyItelFriend.json"   //添加联系人接口
#define DEL_FRIEND_INTERFACE @"/contact/removeItelFriend.json"
#define SEARCH_USER_INTERFACE @"/contact/searchUser.json"
#define MATCH_ADDRESS_BOOK_INTERFACE @"/contact/matchLocalContactsUser.json"
#define ADD_USER_BLACK_INTERFACE @"/blacklist/addItelBlack.json"
#define REMOVE_FROM_BLACK_INTERFACE @"/blacklist/removeItelBlack.json"
#define EDIT_USER_ALIAS_INTERFACE @"/contact/updateItelFriend.json"
#define REFRESH_FRIENDS_LIST_INTERFACE @"/contact/loadItelContacts.json"
#define REFRESH_BLACK_LIST_INTERFACE @"/blacklist/loadItelBlackLists.json"
#define UPLOAD_IMAGE_INTERFACE @"/upload/uploadImg.json"
#define MODIFY_PERSIONAL_INTERFACE @"/user/updateUser.json"
#define MODIFY_PERSIONAL_TELEPHONE_INTERFACE @"/com/isRepeatPhone.json" //提交手机号码
#define MODIFY_PERSIONAL_TELEPHONE_CHECKCODE_INTERFACE @"/com/modifyPhone.json" //提交验证码
#define MODIFY_PERSIONAL_TELEPHONE_SEND_MESSAGE_CODE_INTERFACE @"/com/sendMassageByPhone.json"
#define MODIFY_PERSIONAL_PASSWORD_INTERFACE @"/safety/updatePassword.json"
#define SECURETY_GET_PASSWORD_PROTECTION_INTERFACE @"/safety/getPasswordProtection.json"
#define SECURETY_ANSWER_PROTECTION_QUESTION_INTERFACE @"/safety/checkPasswordProtection.json"
#define SECURETY_MODIFY_PASSWORD_PROTECTION_INTERFACE @"/safety/saveOrUpdatePasswordProtection.json"
#define MESSAGE_SEARCH_FOR_NEW_MESSAGE_INTERFACE @"/contact/isApplyMsg.json"
#define MESSAGE_REFRESH_MESSAGE_LIST_INTERFACE @"/contact/getApplyMsg.json"
#define MESSAGE_ACCEPT_INVITITION_INTERFACE @"/contact/submitApply.json"

#pragma mark - 通知

#define ADD_FIRIEND_NOTIFICATION @"inviteItelUser"
#define ADD_TO_BLACK_LIST_NOTIFICATION @"addBlack"
#define DEL_USER_NOTIFICATION @"delItelUser"
#define SEARCH_STRANGER_NOTIFICATION @"searchStranger"

#endif
