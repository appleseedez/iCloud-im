//
//  thread.h
//  test
//
//  Created by chenjianjun on 14-1-8.
//  Copyright (c) 2014年 hzcw. All rights reserved.
//

#ifndef __hzcw__thread__
#define __hzcw__thread__

#include <algorithm>
#include <list>
#include <string>
#include <vector>
#include <pthread.h>

#include "common.h"

namespace hzcw
{
    class Thread;
    
    class Runnable {
    public:
        virtual ~Runnable() {}
        virtual void Run(Thread* thread) = 0;
        
    protected:
        Runnable() {}
        
    private:
        DISALLOW_COPY_AND_ASSIGN(Runnable);
    };
    
    class ThreadManager {
    public:
        ThreadManager();
        ~ThreadManager();
        
        static ThreadManager* Instance();
        
        Thread* CurrentThread();
        void SetCurrentThread(Thread* thread);
        
        Thread *WrapCurrentThread();
        void UnwrapCurrentThread();
        
    private:
        pthread_key_t key_;
        
        DISALLOW_COPY_AND_ASSIGN(ThreadManager);
    };
    
    struct ThreadInit
    {
        Thread* thread;
        Runnable* runnable;
    };
    
    enum ThreadPriority
    {
        PRIORITY_IDLE = -1,
        PRIORITY_NORMAL = 0,
        PRIORITY_ABOVE_NORMAL = 1,
        PRIORITY_HIGH = 2,
    };
    
    class Thread
    {
    public:
        explicit Thread();
        virtual ~Thread();
        
        static Thread* Current();
        
        bool IsCurrent() const {
            return Current() == this;
        }
        
        static bool SleepMs(int millis);
        bool SetName(const std::string& name, const void* obj);
        bool SetPriority(ThreadPriority priority);
        
        bool started() const { return started_; }
        bool Start(Runnable* runnable);
        virtual void Stop();
        
        virtual void Run();
        
        bool WrapCurrent();
        void UnwrapCurrent();
        bool IsOwned();
        bool WrapCurrentWithThreadManager(ThreadManager* thread_manager);
        
    protected:
        // Blocks the calling thread until this thread has terminated.
        void Join();
        
    private:
        static void *PreRun(void *pv);
        
    private:
        std::string name_;
        ThreadPriority priority_;
        bool started_;
        pthread_t thread_;
        bool owned_;
        bool delete_self_when_complete_;
    };
}

#endif /* defined(__hzcw__thread__) */
