//
//  common.h
//  test
//
//  Created by chenjianjun on 14-1-8.
//  Copyright (c) 2014年 hzcw. All rights reserved.
//

#ifndef __hzcw_common_h__
#define __hzcw_common_h__

namespace hzcw
{
// A macro to disallow the evil copy constructor and operator= functions
// This should be used in the private: declarations for a class
#define DISALLOW_COPY_AND_ASSIGN(TypeName)    \
TypeName(const TypeName&);                    \
void operator=(const TypeName&)
    
#define LIBJINGLE_DEFINE_STATIC_LOCAL(type, name, arguments) \
static type& name = *new type arguments
}

#endif
