//+------------------------------------------------------------------+
//|                                                       MqlZmq.mqh |
//|                                          Copyright 2016, Li Ding |
//|                                            dingmaotu@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Li Ding"
#property link      "dingmaotu@hotmail.com"
#property strict

#include "Common.mqh"
#include "AtomicCounter.mqh"
#include "Z85.mqh"
#include "Socket.mqh"
//+------------------------------------------------------------------+
//| Definitions from zmq.h                                           |
//+------------------------------------------------------------------+
#define ZMQ_VERSION_MAJOR 4
#define ZMQ_VERSION_MINOR 2
#define ZMQ_VERSION_PATCH 0

#define ZMQ_HAS_CAPABILITIES 1

#import "libzmq.dll"
// Error code
int zmq_errno(void);
// Resolves system errors and 0MQ errors to human-readable string
intptr_t zmq_strerror(int errnum);
// Run-time API version detection
void zmq_version(int &major,int &minor,int &patch);
// Probe library capabilities
int zmq_has(const char &capability[]);
#import
//+------------------------------------------------------------------+
//| ZMQ global utilities                                             |
//+------------------------------------------------------------------+
class Zmq
  {
protected:
   static bool       has(string cap);
public:
   //--- Capabilities
   static bool       hasIpc() {return has("ipc");}  // ipc - the library supports the ipc:// protocol
   static bool       hasPgm() {return has("pgm");}  // pgm - the library supports the pgm:// protocol
   static bool       hasTipc() {return has("tipc");};  // tipc - the library supports the tipc:// protocol
   static bool       hasNorm() {return has("norm");};  // norm - the library supports the norm:// protocol
   static bool       hasCurve() {return has("curve");};  // curve-the library supports the CURVE security mechanism
   static bool       hasGssApi() {return has("gssapi");};  // gssapi-the library supports the GSSAPI security mechanism

   //--- Error handling
   static int        errorNumber() {return zmq_errno();}
   static string     errorMessage(int error=0);

   //--- Version
   static string     getVersion();
  };
//+------------------------------------------------------------------+
//| Wrap zmq_has                                                     |
//+------------------------------------------------------------------+
bool Zmq::has(string cap)
  {
   uchar capstr[];
   StringToUtf8(cap,capstr);
   bool res=(ZMQ_HAS_CAPABILITIES==zmq_has(capstr));
   ArrayFree(capstr);
   return res;
  }
//+------------------------------------------------------------------+
//| Wraps zmq_strerror                                               |
//+------------------------------------------------------------------+
string Zmq::errorMessage(int error)
  {
   intptr_t ref=error>0?zmq_strerror(error):zmq_strerror(zmq_errno());
   return StringFromUtf8Pointer(ref);
  }
//+------------------------------------------------------------------+
//| Get version string of current zmq                                |
//+------------------------------------------------------------------+
string Zmq::getVersion(void)
  {
   int major,minor,patch;
   zmq_version(major,minor,patch);
   return StringFormat("%d.%d.%d", major, minor, patch);
  }
//+------------------------------------------------------------------+
