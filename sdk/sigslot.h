#ifndef _SIGSLOT_H__
#define _SIGSLOT_H__

#include <list>
#include <set>
#include <stdlib.h>

#define SIGSLOT_DEFAULT_MT_POLICY single_threaded

class single_threaded
{
public:
    single_threaded()
    {
        ;
    }
    
    virtual ~single_threaded()
    {
        ;
    }
    
    virtual void lock()
    {
        ;
    }
    
    virtual void unlock()
    {
        ;
    }
};

template<class mt_policy>
class lock_block
{
public:
    mt_policy *m_mutex;
    
    lock_block(mt_policy *mtx)
    : m_mutex(mtx)
    {
        m_mutex->lock();
    }
    
    ~lock_block()
    {
        m_mutex->unlock();
    }
};

class has_slots_interface;


template<class arg1_type, class mt_policy>
class _connection_base1
{
public:
    virtual ~_connection_base1() {}
    virtual has_slots_interface* getdest() const = 0;
    virtual void emit(arg1_type) = 0;
    virtual _connection_base1<arg1_type, mt_policy>* clone() = 0;
    virtual _connection_base1<arg1_type, mt_policy>* duplicate(has_slots_interface* pnewdest) = 0;
};

template<class dest_type, class arg1_type, class mt_policy>
class _connection1 : public _connection_base1<arg1_type, mt_policy>
{
public:
    _connection1()
    {
        m_pobject = NULL;
        m_pmemfun = NULL;
    }
    
    _connection1(dest_type* pobject, void (dest_type::*pmemfun)(arg1_type))
    {
        m_pobject = pobject;
        m_pmemfun = pmemfun;
    }
    
    virtual ~_connection1()
    {
    }
    
    virtual _connection_base1<arg1_type, mt_policy>* clone()
    {
        return new _connection1<dest_type, arg1_type, mt_policy>(*this);
    }
    
    virtual _connection_base1<arg1_type, mt_policy>* duplicate(has_slots_interface* pnewdest)
    {
        return new _connection1<dest_type, arg1_type, mt_policy>((dest_type *)pnewdest, m_pmemfun);
    }
    
    virtual void emit(arg1_type a1)
    {
        (m_pobject->*m_pmemfun)(a1);
    }
    
    virtual has_slots_interface* getdest() const
    {
        return m_pobject;
    }
    
private:
    dest_type* m_pobject;
    void (dest_type::* m_pmemfun)(arg1_type);
};


class _signal_base_interface
{
public:
    virtual void slot_disconnect(has_slots_interface* pslot) = 0;
    virtual void slot_duplicate(const has_slots_interface* poldslot, has_slots_interface* pnewslot) = 0;
};

class has_slots_interface
{
public:
    has_slots_interface()
    {
        ;
    }
    
    virtual void signal_connect(_signal_base_interface* sender) = 0;
    
    virtual void signal_disconnect(_signal_base_interface* sender) = 0;
    
    virtual ~has_slots_interface()
    {
    }
    
    virtual void disconnect_all() = 0;
};

template<class mt_policy>
class _signal_base : public _signal_base_interface, public mt_policy
{
};

template<class arg1_type, class mt_policy>
class _signal_base1 : public _signal_base<mt_policy>
{
public:
    typedef std::list<_connection_base1<arg1_type, mt_policy> *>  connections_list;
    
    _signal_base1()
    {
        ;
    }
    
    _signal_base1(const _signal_base1<arg1_type, mt_policy>& s)
    : _signal_base<mt_policy>(s)
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::const_iterator it = s.m_connected_slots.begin();
        typename connections_list::const_iterator itEnd = s.m_connected_slots.end();
        
        while(it != itEnd)
        {
            (*it)->getdest()->signal_connect(this);
            m_connected_slots.push_back((*it)->clone());
            
            ++it;
        }
    }
    
    void slot_duplicate(const has_slots_interface* oldtarget, has_slots_interface* newtarget)
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::iterator it = m_connected_slots.begin();
        typename connections_list::iterator itEnd = m_connected_slots.end();
        
        while(it != itEnd)
        {
            if((*it)->getdest() == oldtarget)
            {
                m_connected_slots.push_back((*it)->duplicate(newtarget));
            }
            
            ++it;
        }
    }
    
    ~_signal_base1()
    {
        disconnect_all();
    }
    
    bool is_empty()
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::const_iterator it = m_connected_slots.begin();
        typename connections_list::const_iterator itEnd = m_connected_slots.end();
        return it == itEnd;
    }
    
    void disconnect_all()
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::const_iterator it = m_connected_slots.begin();
        typename connections_list::const_iterator itEnd = m_connected_slots.end();
        
        while(it != itEnd)
        {
            (*it)->getdest()->signal_disconnect(this);
            delete *it;
            
            ++it;
        }
        
        m_connected_slots.erase(m_connected_slots.begin(), m_connected_slots.end());
    }
    
    void disconnect(has_slots_interface* pclass)
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::iterator it = m_connected_slots.begin();
        typename connections_list::iterator itEnd = m_connected_slots.end();
        
        while(it != itEnd)
        {
            if((*it)->getdest() == pclass)
            {
                delete *it;
                m_connected_slots.erase(it);
                pclass->signal_disconnect(this);
                return;
            }
            
            ++it;
        }
    }
    
    void slot_disconnect(has_slots_interface* pslot)
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::iterator it = m_connected_slots.begin();
        typename connections_list::iterator itEnd = m_connected_slots.end();
        
        while(it != itEnd)
        {
            typename connections_list::iterator itNext = it;
            ++itNext;
            
            if((*it)->getdest() == pslot)
            {
                delete *it;
                m_connected_slots.erase(it);
            }
            
            it = itNext;
        }
    }
    
    
protected:
    connections_list m_connected_slots;
};

template<class arg1_type, class mt_policy = SIGSLOT_DEFAULT_MT_POLICY>
class signal1 : public _signal_base1<arg1_type, mt_policy>
{
public:
    typedef _signal_base1<arg1_type, mt_policy> base;
    typedef typename base::connections_list connections_list;
    using base::m_connected_slots;
    
    signal1()
    {
        ;
    }
    
    signal1(const signal1<arg1_type, mt_policy>& s)
    : _signal_base1<arg1_type, mt_policy>(s)
    {
        ;
    }
    
    template<class desttype>
    void connect(desttype* pclass, void (desttype::*pmemfun)(arg1_type))
    {
        lock_block<mt_policy> lock(this);
        _connection1<desttype, arg1_type, mt_policy>* conn =
        new _connection1<desttype, arg1_type, mt_policy>(pclass, pmemfun);
        m_connected_slots.push_back(conn);
        pclass->signal_connect(this);
    }
    
    void emit(arg1_type a1)
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::const_iterator itNext, it = m_connected_slots.begin();
        typename connections_list::const_iterator itEnd = m_connected_slots.end();
        
        while(it != itEnd)
        {
            itNext = it;
            ++itNext;
            
            (*it)->emit(a1);
            
            it = itNext;
        }
    }
    
    void operator()(arg1_type a1)
    {
        lock_block<mt_policy> lock(this);
        typename connections_list::const_iterator itNext, it = m_connected_slots.begin();
        typename connections_list::const_iterator itEnd = m_connected_slots.end();
        
        while(it != itEnd)
        {
            itNext = it;
            ++itNext;
            
            (*it)->emit(a1);
            
            it = itNext;
        }
    }
};

#endif
