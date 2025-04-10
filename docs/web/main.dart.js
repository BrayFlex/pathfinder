(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.kA(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.fU(b)
return new s(c,this)}:function(){if(s===null)s=A.fU(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.fU(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
fY(a,b,c,d){return{i:a,p:b,e:c,x:d}},
fV(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.fW==null){A.kl()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.c(A.hz("Return interceptor for "+A.p(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.f5
if(o==null)o=$.f5=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.kp(a)
if(p!=null)return p
if(typeof a=="function")return B.x
s=Object.getPrototypeOf(a)
if(s==null)return B.m
if(s===Object.prototype)return B.m
if(typeof q=="function"){o=$.f5
if(o==null)o=$.f5=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.j,enumerable:false,writable:true,configurable:true})
return B.j}return B.j},
he(a,b){if(a<0||a>4294967295)throw A.c(A.aY(a,0,4294967295,"length",null))
return J.hf(new Array(a),b)},
hd(a,b){if(a<0||a>4294967295)throw A.c(A.aY(a,0,4294967295,"length",null))
return J.hf(new Array(a),b)},
hf(a,b){var s=A.d(a,b.i("t<0>"))
s.$flags=1
return s},
hg(a){if(a<256)switch(a){case 9:case 10:case 11:case 12:case 13:case 32:case 133:case 160:return!0
default:return!1}switch(a){case 5760:case 8192:case 8193:case 8194:case 8195:case 8196:case 8197:case 8198:case 8199:case 8200:case 8201:case 8202:case 8232:case 8233:case 8239:case 8287:case 12288:case 65279:return!0
default:return!1}},
iN(a,b){var s,r
for(s=a.length;b<s;){r=a.charCodeAt(b)
if(r!==32&&r!==13&&!J.hg(r))break;++b}return b},
iO(a,b){var s,r,q
for(s=a.length;b>0;b=r){r=b-1
if(!(r<s))return A.e(a,r)
q=a.charCodeAt(r)
if(q!==32&&q!==13&&!J.hg(q))break}return b},
aN(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bl.prototype
return J.cm.prototype}if(typeof a=="string")return J.aT.prototype
if(a==null)return J.bm.prototype
if(typeof a=="boolean")return J.cl.prototype
if(Array.isArray(a))return J.t.prototype
if(typeof a!="object"){if(typeof a=="function")return J.aw.prototype
if(typeof a=="symbol")return J.bp.prototype
if(typeof a=="bigint")return J.bn.prototype
return a}if(a instanceof A.n)return a
return J.fV(a)},
cY(a){if(typeof a=="string")return J.aT.prototype
if(a==null)return a
if(Array.isArray(a))return J.t.prototype
if(typeof a!="object"){if(typeof a=="function")return J.aw.prototype
if(typeof a=="symbol")return J.bp.prototype
if(typeof a=="bigint")return J.bn.prototype
return a}if(a instanceof A.n)return a
return J.fV(a)},
fl(a){if(a==null)return a
if(Array.isArray(a))return J.t.prototype
if(typeof a!="object"){if(typeof a=="function")return J.aw.prototype
if(typeof a=="symbol")return J.bp.prototype
if(typeof a=="bigint")return J.bn.prototype
return a}if(a instanceof A.n)return a
return J.fV(a)},
i4(a){if(typeof a=="number")return J.aS.prototype
if(a==null)return a
if(!(a instanceof A.n))return J.b2.prototype
return a},
U(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aN(a).H(a,b)},
iq(a,b){if(typeof a=="number"&&typeof b=="number")return a-b
return J.i4(a).u(a,b)},
h2(a,b){return J.fl(a).h(a,b)},
h3(a,b){return J.fl(a).a2(a,b)},
Y(a){return J.aN(a).gB(a)},
ir(a){return J.cY(a).gah(a)},
ba(a){return J.fl(a).gU(a)},
aG(a){return J.cY(a).gq(a)},
is(a){return J.aN(a).gL(a)},
it(a,b){return J.fl(a).a4(a,b)},
c8(a){return J.aN(a).n(a)},
iu(a,b){return J.i4(a).bo(a,b)},
ck:function ck(){},
cl:function cl(){},
bm:function bm(){},
bo:function bo(){},
ax:function ax(){},
cB:function cB(){},
b2:function b2(){},
aw:function aw(){},
bn:function bn(){},
bp:function bp(){},
t:function t(a){this.$ti=a},
dm:function dm(a){this.$ti=a},
bd:function bd(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aS:function aS(){},
bl:function bl(){},
cm:function cm(){},
aT:function aT(){}},A={fB:function fB(){},
ai(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
eO(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
hw(a,b,c){return A.eO(A.ai(A.ai(c,a),b))},
fT(a,b,c){return a},
fX(a){var s,r
for(s=$.T.length,r=0;r<s;++r)if(a===$.T[r])return!0
return!1},
eN(a,b,c,d){A.dD(b,"start")
if(c!=null){A.dD(c,"end")
if(b>c)A.as(A.aY(b,0,c,"start",null))}return new A.bF(a,b,c,d.i("bF<0>"))},
hb(){return new A.b0("No element")},
iM(){return new A.b0("Too few elements")},
aU:function aU(a){this.a=a},
dE:function dE(){},
bg:function bg(){},
v:function v(){},
bF:function bF(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
R:function R(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bu:function bu(a,b,c){this.a=a
this.b=b
this.$ti=c},
bv:function bv(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
bw:function bw(a,b,c){this.a=a
this.b=b
this.$ti=c},
bH:function bH(a,b,c){this.a=a
this.b=b
this.$ti=c},
bI:function bI(a,b,c){this.a=a
this.b=b
this.$ti=c},
w:function w(){},
S:function S(a,b){this.a=a
this.$ti=b},
ic(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
l2(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.aU.b(a)},
p(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.c8(a)
return s},
cC(a){var s,r=$.hn
if(r==null)r=$.hn=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
ho(a){var s,r
if(!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(a))return null
s=parseFloat(a)
if(isNaN(s)){r=B.i.cn(a)
if(r==="NaN"||r==="+NaN"||r==="-NaN")return s
return null}return s},
dA(a){return A.iU(a)},
iU(a){var s,r,q,p
if(a instanceof A.n)return A.K(A.aO(a),null)
s=J.aN(a)
if(s===B.w||s===B.y||t.ak.b(a)){r=B.k(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.K(A.aO(a),null)},
hp(a){if(a==null||typeof a=="number"||A.fP(a))return J.c8(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.au)return a.n(0)
if(a instanceof A.a2)return a.bj(!0)
return"Instance of '"+A.dA(a)+"'"},
iV(){return Date.now()},
iX(){var s,r
if($.dB!==0)return
$.dB=1000
if(typeof window=="undefined")return
s=window
if(s==null)return
if(!!s.dartUseDateNowForTicks)return
r=s.performance
if(r==null)return
if(typeof r.now!="function")return
$.dB=1e6
$.dC=new A.dz(r)},
iW(a){var s=a.$thrownJsError
if(s==null)return null
return A.aF(s)},
a4(a){throw A.c(A.i0(a))},
e(a,b){if(a==null)J.aG(a)
throw A.c(A.fh(a,b))},
fh(a,b){var s,r="index",q=null
if(!A.hU(b))return new A.a6(!0,b,r,q)
s=A.P(J.aG(a))
if(b<0||b>=s)return A.dk(b,s,a,q,r)
return new A.aX(q,q,!0,b,r,"Value not in range")},
i0(a){return new A.a6(!0,a,null,null)},
c(a){return A.i6(new Error(),a)},
i6(a,b){var s
if(b==null)b=new A.aj()
a.dartException=b
s=A.kC
if("defineProperty" in Object){Object.defineProperty(a,"message",{get:s})
a.name=""}else a.toString=s
return a},
kC(){return J.c8(this.dartException)},
as(a){throw A.c(a)},
fx(a,b){throw A.i6(b,a)},
A(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.fx(A.jz(a,b,c),s)},
jz(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t.aH.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.bG("'"+s+"': Cannot "+o+" "+l+k+n)},
l(a){throw A.c(A.ac(a))},
ak(a){var s,r,q,p,o,n
a=A.kx(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.d([],t.U)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.eP(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
eQ(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
hy(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
fC(a,b){var s=b==null,r=s?null:b.method
return new A.cn(a,r,s?null:b.receiver)},
c7(a){if(a==null)return new A.dt(a)
if(typeof a!=="object")return a
if("dartException" in a)return A.aP(a,a.dartException)
return A.k1(a)},
aP(a,b){if(t.Q.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
k1(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.b.c1(r,16)&8191)===10)switch(q){case 438:return A.aP(a,A.fC(A.p(s)+" (Error "+q+")",null))
case 445:case 5007:A.p(s)
return A.aP(a,new A.bB())}}if(a instanceof TypeError){p=$.id()
o=$.ie()
n=$.ig()
m=$.ih()
l=$.ik()
k=$.il()
j=$.ij()
$.ii()
i=$.io()
h=$.im()
g=p.a1(s)
if(g!=null)return A.aP(a,A.fC(A.aD(s),g))
else{g=o.a1(s)
if(g!=null){g.method="call"
return A.aP(a,A.fC(A.aD(s),g))}else if(n.a1(s)!=null||m.a1(s)!=null||l.a1(s)!=null||k.a1(s)!=null||j.a1(s)!=null||m.a1(s)!=null||i.a1(s)!=null||h.a1(s)!=null){A.aD(s)
return A.aP(a,new A.bB())}}return A.aP(a,new A.cJ(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.bD()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.aP(a,new A.a6(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.bD()
return a},
aF(a){var s
if(a==null)return new A.bW(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.bW(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
i8(a){if(a==null)return J.Y(a)
if(typeof a=="object")return A.cC(a)
return J.Y(a)},
kf(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.l(0,a[s],a[r])}return b},
jH(a,b,c,d,e,f){t.Y.a(a)
switch(A.P(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.c(new A.eX("Unsupported number of arguments for wrapped closure"))},
ff(a,b){var s=a.$identity
if(!!s)return s
s=A.k8(a,b)
a.$identity=s
return s},
k8(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.jH)},
iB(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.cF().constructor.prototype):Object.create(new A.aR(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.h9(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.ix(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.h9(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
ix(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.c("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.iv)}throw A.c("Error in functionType of tearoff")},
iy(a,b,c,d){var s=A.h8
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
h9(a,b,c,d){if(c)return A.iA(a,b,d)
return A.iy(b.length,d,a,b)},
iz(a,b,c,d){var s=A.h8,r=A.iw
switch(b?-1:a){case 0:throw A.c(new A.cE("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
iA(a,b,c){var s,r
if($.h6==null)$.h6=A.h5("interceptor")
if($.h7==null)$.h7=A.h5("receiver")
s=b.length
r=A.iz(s,c,a,b)
return r},
fU(a){return A.iB(a)},
iv(a,b){return A.c0(v.typeUniverse,A.aO(a.a),b)},
h8(a){return a.a},
iw(a){return a.b},
h5(a){var s,r,q,p=new A.aR("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.c(A.bc("Field name "+a+" not found.",null))},
i2(a){if(a==null)A.k3("boolean expression must not be null")
return a},
k3(a){throw A.c(new A.cK(a))},
l3(a){throw A.c(new A.cM(a))},
kh(a){return v.getIsolateTag(a)},
kp(a){var s,r,q,p,o,n=A.aD($.i5.$1(a)),m=$.fi[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.fp[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.jw($.i_.$2(a,n))
if(q!=null){m=$.fi[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.fp[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.fq(s)
$.fi[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.fp[n]=s
return s}if(p==="-"){o=A.fq(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.i9(a,s)
if(p==="*")throw A.c(A.hz(n))
if(v.leafTags[n]===true){o=A.fq(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.i9(a,s)},
i9(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.fY(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
fq(a){return J.fY(a,!1,null,!!a.$iQ)},
kr(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.fq(s)
else return J.fY(s,c,null,null)},
kl(){if(!0===$.fW)return
$.fW=!0
A.km()},
km(){var s,r,q,p,o,n,m,l
$.fi=Object.create(null)
$.fp=Object.create(null)
A.kk()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.ia.$1(o)
if(n!=null){m=A.kr(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
kk(){var s,r,q,p,o,n,m=B.n()
m=A.b8(B.o,A.b8(B.p,A.b8(B.l,A.b8(B.l,A.b8(B.q,A.b8(B.r,A.b8(B.t(B.k),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.i5=new A.fm(p)
$.i_=new A.fn(o)
$.ia=new A.fo(n)},
b8(a,b){return a(b)||b},
jh(a,b){var s,r
for(s=0;s<a.length;++s){r=a[s]
if(!(s<b.length))return A.e(b,s)
if(!J.U(r,b[s]))return!1}return!0},
kb(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
kx(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
j:function j(a,b){this.a=a
this.b=b},
G:function G(a,b){this.a=a
this.b=b},
B:function B(a,b){this.a=a
this.b=b},
bU:function bU(a){this.a=a},
bf:function bf(){},
av:function av(a,b,c){this.a=a
this.b=b
this.$ti=c},
dz:function dz(a){this.a=a},
eP:function eP(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bB:function bB(){},
cn:function cn(a,b,c){this.a=a
this.b=b
this.c=c},
cJ:function cJ(a){this.a=a},
dt:function dt(a){this.a=a},
bW:function bW(a){this.a=a
this.b=null},
au:function au(){},
cb:function cb(){},
cc:function cc(){},
cH:function cH(){},
cF:function cF(){},
aR:function aR(a,b){this.a=a
this.b=b},
cM:function cM(a){this.a=a},
cE:function cE(a){this.a=a},
cK:function cK(a){this.a=a},
aJ:function aJ(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
dr:function dr(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
br:function br(a,b){this.a=a
this.$ti=b},
bq:function bq(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
fm:function fm(a){this.a=a},
fn:function fn(a){this.a=a},
fo:function fo(a){this.a=a},
a2:function a2(){},
aC:function aC(){},
b5:function b5(){},
ap(a,b,c){if(a>>>0!==a||a>=c)throw A.c(A.fh(b,a))},
co:function co(){},
bz:function bz(){},
cp:function cp(){},
aW:function aW(){},
bx:function bx(){},
by:function by(){},
cq:function cq(){},
cr:function cr(){},
cs:function cs(){},
ct:function ct(){},
cu:function cu(){},
cv:function cv(){},
cw:function cw(){},
bA:function bA(){},
cx:function cx(){},
bQ:function bQ(){},
bR:function bR(){},
bS:function bS(){},
bT:function bT(){},
hs(a,b){var s=b.c
return s==null?b.c=A.fM(a,b.x,!0):s},
fG(a,b){var s=b.c
return s==null?b.c=A.bZ(a,"bj",[b.x]):s},
ht(a){var s=a.w
if(s===6||s===7||s===8)return A.ht(a.x)
return s===12||s===13},
iZ(a){return a.as},
ks(a,b){var s,r=b.length
for(s=0;s<r;++s)if(!a[s].b(b[s]))return!1
return!0},
c5(a){return A.cW(v.typeUniverse,a,!1)},
aE(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.aE(a1,s,a3,a4)
if(r===s)return a2
return A.hM(a1,r,!0)
case 7:s=a2.x
r=A.aE(a1,s,a3,a4)
if(r===s)return a2
return A.fM(a1,r,!0)
case 8:s=a2.x
r=A.aE(a1,s,a3,a4)
if(r===s)return a2
return A.hK(a1,r,!0)
case 9:q=a2.y
p=A.b7(a1,q,a3,a4)
if(p===q)return a2
return A.bZ(a1,a2.x,p)
case 10:o=a2.x
n=A.aE(a1,o,a3,a4)
m=a2.y
l=A.b7(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.fK(a1,n,l)
case 11:k=a2.x
j=a2.y
i=A.b7(a1,j,a3,a4)
if(i===j)return a2
return A.hL(a1,k,i)
case 12:h=a2.x
g=A.aE(a1,h,a3,a4)
f=a2.y
e=A.jZ(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.hJ(a1,g,e)
case 13:d=a2.y
a4+=d.length
c=A.b7(a1,d,a3,a4)
o=a2.x
n=A.aE(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.fL(a1,n,c,!0)
case 14:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.c(A.ca("Attempted to substitute unexpected RTI kind "+a0))}},
b7(a,b,c,d){var s,r,q,p,o=b.length,n=A.fb(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.aE(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
k_(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.fb(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.aE(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
jZ(a,b,c,d){var s,r=b.a,q=A.b7(a,r,c,d),p=b.b,o=A.b7(a,p,c,d),n=b.c,m=A.k_(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.cQ()
s.a=q
s.b=o
s.c=m
return s},
d(a,b){a[v.arrayRti]=b
return a},
i3(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.ki(s)
return a.$S()}return null},
kn(a,b){var s
if(A.ht(b))if(a instanceof A.au){s=A.i3(a)
if(s!=null)return s}return A.aO(a)},
aO(a){if(a instanceof A.n)return A.J(a)
if(Array.isArray(a))return A.F(a)
return A.fO(J.aN(a))},
F(a){var s=a[v.arrayRti],r=t.u
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
J(a){var s=a.$ti
return s!=null?s:A.fO(a)},
fO(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.jG(a,s)},
jG(a,b){var s=a instanceof A.au?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.jr(v.typeUniverse,s.name)
b.$ccache=r
return r},
ki(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.cW(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
N(a){return A.ab(A.J(a))},
fS(a){var s
if(a instanceof A.a2)return A.ke(a.$r,a.aF())
s=a instanceof A.au?A.i3(a):null
if(s!=null)return s
if(t.dm.b(a))return J.is(a).a
if(Array.isArray(a))return A.F(a)
return A.aO(a)},
ab(a){var s=a.r
return s==null?a.r=A.hQ(a):s},
hQ(a){var s,r,q=a.as,p=q.replace(/\*/g,"")
if(p===q)return a.r=new A.cV(a)
s=A.cW(v.typeUniverse,p,!0)
r=s.r
return r==null?s.r=A.hQ(s):r},
ke(a,b){var s,r,q=b,p=q.length
if(p===0)return t.bQ
if(0>=p)return A.e(q,0)
s=A.c0(v.typeUniverse,A.fS(q[0]),"@<0>")
for(r=1;r<p;++r){if(!(r<q.length))return A.e(q,r)
s=A.hN(v.typeUniverse,s,A.fS(q[r]))}return A.c0(v.typeUniverse,s,a)},
a5(a){return A.ab(A.cW(v.typeUniverse,a,!1))},
jF(a){var s,r,q,p,o,n,m=this
if(m===t.K)return A.aq(m,a,A.jM)
if(!A.ar(m))s=m===t.c
else s=!0
if(s)return A.aq(m,a,A.jQ)
s=m.w
if(s===7)return A.aq(m,a,A.jD)
if(s===1)return A.aq(m,a,A.hV)
r=s===6?m.x:m
q=r.w
if(q===8)return A.aq(m,a,A.jI)
if(r===t.S)p=A.hU
else if(r===t.i||r===t.di)p=A.jL
else if(r===t.N)p=A.jO
else p=r===t.y?A.fP:null
if(p!=null)return A.aq(m,a,p)
if(q===9){o=r.x
if(r.y.every(A.ko)){m.f="$i"+o
if(o==="k")return A.aq(m,a,A.jK)
return A.aq(m,a,A.jP)}}else if(q===11){n=A.kb(r.x,r.y)
return A.aq(m,a,n==null?A.hV:n)}return A.aq(m,a,A.jB)},
aq(a,b,c){a.b=c
return a.b(b)},
jE(a){var s,r=this,q=A.jA
if(!A.ar(r))s=r===t.c
else s=!0
if(s)q=A.jx
else if(r===t.K)q=A.jv
else{s=A.c6(r)
if(s)q=A.jC}r.a=q
return r.a(a)},
cX(a){var s=a.w,r=!0
if(!A.ar(a))if(!(a===t.c))if(!(a===t.W))if(s!==7)if(!(s===6&&A.cX(a.x)))r=s===8&&A.cX(a.x)||a===t.P||a===t.T
return r},
jB(a){var s=this
if(a==null)return A.cX(s)
return A.i7(v.typeUniverse,A.kn(a,s),s)},
jD(a){if(a==null)return!0
return this.x.b(a)},
jP(a){var s,r=this
if(a==null)return A.cX(r)
s=r.f
if(a instanceof A.n)return!!a[s]
return!!J.aN(a)[s]},
jK(a){var s,r=this
if(a==null)return A.cX(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.n)return!!a[s]
return!!J.aN(a)[s]},
jA(a){var s=this
if(a==null){if(A.c6(s))return a}else if(s.b(a))return a
A.hR(a,s)},
jC(a){var s=this
if(a==null)return a
else if(s.b(a))return a
A.hR(a,s)},
hR(a,b){throw A.c(A.hI(A.hB(a,A.K(b,null))))},
c4(a,b,c,d){if(A.i7(v.typeUniverse,a,b))return a
throw A.c(A.hI("The type argument '"+A.K(a,null)+"' is not a subtype of the type variable bound '"+A.K(b,null)+"' of type variable '"+c+"' in '"+d+"'."))},
hB(a,b){return A.ch(a)+": type '"+A.K(A.fS(a),null)+"' is not a subtype of type '"+b+"'"},
hI(a){return new A.bX("TypeError: "+a)},
M(a,b){return new A.bX("TypeError: "+A.hB(a,b))},
jI(a){var s=this,r=s.w===6?s.x:s
return r.x.b(a)||A.fG(v.typeUniverse,r).b(a)},
jM(a){return a!=null},
jv(a){if(a!=null)return a
throw A.c(A.M(a,"Object"))},
jQ(a){return!0},
jx(a){return a},
hV(a){return!1},
fP(a){return!0===a||!1===a},
fN(a){if(!0===a)return!0
if(!1===a)return!1
throw A.c(A.M(a,"bool"))},
kU(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.c(A.M(a,"bool"))},
kT(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.c(A.M(a,"bool?"))},
aM(a){if(typeof a=="number")return a
throw A.c(A.M(a,"double"))},
kW(a){if(typeof a=="number")return a
if(a==null)return a
throw A.c(A.M(a,"double"))},
kV(a){if(typeof a=="number")return a
if(a==null)return a
throw A.c(A.M(a,"double?"))},
hU(a){return typeof a=="number"&&Math.floor(a)===a},
P(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.c(A.M(a,"int"))},
kY(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.c(A.M(a,"int"))},
kX(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.c(A.M(a,"int?"))},
jL(a){return typeof a=="number"},
jt(a){if(typeof a=="number")return a
throw A.c(A.M(a,"num"))},
kZ(a){if(typeof a=="number")return a
if(a==null)return a
throw A.c(A.M(a,"num"))},
ju(a){if(typeof a=="number")return a
if(a==null)return a
throw A.c(A.M(a,"num?"))},
jO(a){return typeof a=="string"},
aD(a){if(typeof a=="string")return a
throw A.c(A.M(a,"String"))},
l_(a){if(typeof a=="string")return a
if(a==null)return a
throw A.c(A.M(a,"String"))},
jw(a){if(typeof a=="string")return a
if(a==null)return a
throw A.c(A.M(a,"String?"))},
hY(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.K(a[q],b)
return s},
jU(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.hY(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.K(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
hS(a4,a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=", ",a3=null
if(a6!=null){s=a6.length
if(a5==null)a5=A.d([],t.U)
else a3=a5.length
r=a5.length
for(q=s;q>0;--q)B.a.h(a5,"T"+(r+q))
for(p=t.cK,o=t.c,n="<",m="",q=0;q<s;++q,m=a2){l=a5.length
k=l-1-q
if(!(k>=0))return A.e(a5,k)
n=n+m+a5[k]
j=a6[q]
i=j.w
if(!(i===2||i===3||i===4||i===5||j===p))l=j===o
else l=!0
if(!l)n+=" extends "+A.K(j,a5)}n+=">"}else n=""
p=a4.x
h=a4.y
g=h.a
f=g.length
e=h.b
d=e.length
c=h.c
b=c.length
a=A.K(p,a5)
for(a0="",a1="",q=0;q<f;++q,a1=a2)a0+=a1+A.K(g[q],a5)
if(d>0){a0+=a1+"["
for(a1="",q=0;q<d;++q,a1=a2)a0+=a1+A.K(e[q],a5)
a0+="]"}if(b>0){a0+=a1+"{"
for(a1="",q=0;q<b;q+=3,a1=a2){a0+=a1
if(c[q+1])a0+="required "
a0+=A.K(c[q+2],a5)+" "+c[q]}a0+="}"}if(a3!=null){a5.toString
a5.length=a3}return n+"("+a0+") => "+a},
K(a,b){var s,r,q,p,o,n,m,l=a.w
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6)return A.K(a.x,b)
if(l===7){s=a.x
r=A.K(s,b)
q=s.w
return(q===12||q===13?"("+r+")":r)+"?"}if(l===8)return"FutureOr<"+A.K(a.x,b)+">"
if(l===9){p=A.k0(a.x)
o=a.y
return o.length>0?p+("<"+A.hY(o,b)+">"):p}if(l===11)return A.jU(a,b)
if(l===12)return A.hS(a,b,null)
if(l===13)return A.hS(a.x,b,a.y)
if(l===14){n=a.x
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.e(b,n)
return b[n]}return"?"},
k0(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
js(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
jr(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.cW(a,b,!1)
else if(typeof m=="number"){s=m
r=A.c_(a,5,"#")
q=A.fb(s)
for(p=0;p<s;++p)q[p]=r
o=A.bZ(a,b,q)
n[b]=o
return o}else return m},
jq(a,b){return A.hO(a.tR,b)},
jp(a,b){return A.hO(a.eT,b)},
cW(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.hG(A.hE(a,null,b,c))
r.set(b,s)
return s},
c0(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.hG(A.hE(a,b,c,!0))
q.set(c,r)
return r},
hN(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.fK(a,b,c.w===10?c.y:[c])
p.set(s,q)
return q},
ao(a,b){b.a=A.jE
b.b=A.jF
return b},
c_(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.V(null,null)
s.w=b
s.as=c
r=A.ao(a,s)
a.eC.set(c,r)
return r},
hM(a,b,c){var s,r=b.as+"*",q=a.eC.get(r)
if(q!=null)return q
s=A.jn(a,b,r,c)
a.eC.set(r,s)
return s},
jn(a,b,c,d){var s,r,q
if(d){s=b.w
if(!A.ar(b))r=b===t.P||b===t.T||s===7||s===6
else r=!0
if(r)return b}q=new A.V(null,null)
q.w=6
q.x=b
q.as=c
return A.ao(a,q)},
fM(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.jm(a,b,r,c)
a.eC.set(r,s)
return s},
jm(a,b,c,d){var s,r,q,p
if(d){s=b.w
r=!0
if(!A.ar(b))if(!(b===t.P||b===t.T))if(s!==7)r=s===8&&A.c6(b.x)
if(r)return b
else if(s===1||b===t.W)return t.P
else if(s===6){q=b.x
if(q.w===8&&A.c6(q.x))return q
else return A.hs(a,b)}}p=new A.V(null,null)
p.w=7
p.x=b
p.as=c
return A.ao(a,p)},
hK(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.jk(a,b,r,c)
a.eC.set(r,s)
return s},
jk(a,b,c,d){var s,r
if(d){s=b.w
if(A.ar(b)||b===t.K||b===t.c)return b
else if(s===1)return A.bZ(a,"bj",[b])
else if(b===t.P||b===t.T)return t.bG}r=new A.V(null,null)
r.w=8
r.x=b
r.as=c
return A.ao(a,r)},
jo(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.V(null,null)
s.w=14
s.x=b
s.as=q
r=A.ao(a,s)
a.eC.set(q,r)
return r},
bY(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
jj(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bZ(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bY(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.V(null,null)
r.w=9
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.ao(a,r)
a.eC.set(p,q)
return q},
fK(a,b,c){var s,r,q,p,o,n
if(b.w===10){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bY(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.V(null,null)
o.w=10
o.x=s
o.y=r
o.as=q
n=A.ao(a,o)
a.eC.set(q,n)
return n},
hL(a,b,c){var s,r,q="+"+(b+"("+A.bY(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.V(null,null)
s.w=11
s.x=b
s.y=c
s.as=q
r=A.ao(a,s)
a.eC.set(q,r)
return r},
hJ(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bY(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bY(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.jj(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.V(null,null)
p.w=12
p.x=b
p.y=c
p.as=r
o=A.ao(a,p)
a.eC.set(r,o)
return o},
fL(a,b,c,d){var s,r=b.as+("<"+A.bY(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.jl(a,b,c,r,d)
a.eC.set(r,s)
return s},
jl(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.fb(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.aE(a,b,r,0)
m=A.b7(a,c,r,0)
return A.fL(a,n,m,c!==m)}}l=new A.V(null,null)
l.w=13
l.x=b
l.y=c
l.as=d
return A.ao(a,l)},
hE(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
hG(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.jc(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.hF(a,r,l,k,!1)
else if(q===46)r=A.hF(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.aB(a.u,a.e,k.pop()))
break
case 94:k.push(A.jo(a.u,k.pop()))
break
case 35:k.push(A.c_(a.u,5,"#"))
break
case 64:k.push(A.c_(a.u,2,"@"))
break
case 126:k.push(A.c_(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.je(a,k)
break
case 38:A.jd(a,k)
break
case 42:p=a.u
k.push(A.hM(p,A.aB(p,a.e,k.pop()),a.n))
break
case 63:p=a.u
k.push(A.fM(p,A.aB(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.hK(p,A.aB(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.jb(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.hH(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.jg(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.aB(a.u,a.e,m)},
jc(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
hF(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===10)o=o.x
n=A.js(s,o.x)[p]
if(n==null)A.as('No "'+p+'" in "'+A.iZ(o)+'"')
d.push(A.c0(s,o,n))}else d.push(p)
return m},
je(a,b){var s,r=a.u,q=A.hD(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bZ(r,p,q))
else{s=A.aB(r,a.e,p)
switch(s.w){case 12:b.push(A.fL(r,s,q,a.n))
break
default:b.push(A.fK(r,s,q))
break}}},
jb(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.hD(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.aB(p,a.e,o)
q=new A.cQ()
q.a=s
q.b=n
q.c=m
b.push(A.hJ(p,r,q))
return
case-4:b.push(A.hL(p,b.pop(),s))
return
default:throw A.c(A.ca("Unexpected state under `()`: "+A.p(o)))}},
jd(a,b){var s=b.pop()
if(0===s){b.push(A.c_(a.u,1,"0&"))
return}if(1===s){b.push(A.c_(a.u,4,"1&"))
return}throw A.c(A.ca("Unexpected extended operation "+A.p(s)))},
hD(a,b){var s=b.splice(a.p)
A.hH(a.u,a.e,s)
a.p=b.pop()
return s},
aB(a,b,c){if(typeof c=="string")return A.bZ(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.jf(a,b,c)}else return c},
hH(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.aB(a,b,c[s])},
jg(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.aB(a,b,c[s])},
jf(a,b,c){var s,r,q=b.w
if(q===10){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==9)throw A.c(A.ca("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.c(A.ca("Bad index "+c+" for "+b.n(0)))},
i7(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.z(a,b,null,c,null,!1)?1:0
r.set(c,s)}if(0===s)return!1
if(1===s)return!0
return!0},
z(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(!A.ar(d))s=d===t.c
else s=!0
if(s)return!0
r=b.w
if(r===4)return!0
if(A.ar(b))return!1
s=b.w
if(s===1)return!0
q=r===14
if(q)if(A.z(a,c[b.x],c,d,e,!1))return!0
p=d.w
s=b===t.P||b===t.T
if(s){if(p===8)return A.z(a,b,c,d.x,e,!1)
return d===t.P||d===t.T||p===7||p===6}if(d===t.K){if(r===8)return A.z(a,b.x,c,d,e,!1)
if(r===6)return A.z(a,b.x,c,d,e,!1)
return r!==7}if(r===6)return A.z(a,b.x,c,d,e,!1)
if(p===6){s=A.hs(a,d)
return A.z(a,b,c,s,e,!1)}if(r===8){if(!A.z(a,b.x,c,d,e,!1))return!1
return A.z(a,A.fG(a,b),c,d,e,!1)}if(r===7){s=A.z(a,t.P,c,d,e,!1)
return s&&A.z(a,b.x,c,d,e,!1)}if(p===8){if(A.z(a,b,c,d.x,e,!1))return!0
return A.z(a,b,c,A.fG(a,d),e,!1)}if(p===7){s=A.z(a,b,c,t.P,e,!1)
return s||A.z(a,b,c,d.x,e,!1)}if(q)return!1
s=r!==12
if((!s||r===13)&&d===t.Y)return!0
o=r===11
if(o&&d===t.gT)return!0
if(p===13){if(b===t.O)return!0
if(r!==13)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.z(a,j,c,i,e,!1)||!A.z(a,i,e,j,c,!1))return!1}return A.hT(a,b.x,c,d.x,e,!1)}if(p===12){if(b===t.O)return!0
if(s)return!1
return A.hT(a,b,c,d,e,!1)}if(r===9){if(p!==9)return!1
return A.jJ(a,b,c,d,e,!1)}if(o&&p===11)return A.jN(a,b,c,d,e,!1)
return!1},
hT(a3,a4,a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.z(a3,a4.x,a5,a6.x,a7,!1))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.z(a3,p[h],a7,g,a5,!1))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.z(a3,p[o+h],a7,g,a5,!1))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.z(a3,k[h],a7,g,a5,!1))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;!0;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.z(a3,e[a+2],a7,g,a5,!1))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
jJ(a,b,c,d,e,f){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.c0(a,b,r[o])
return A.hP(a,p,null,c,d.y,e,!1)}return A.hP(a,b.y,null,c,d.y,e,!1)},
hP(a,b,c,d,e,f,g){var s,r=b.length
for(s=0;s<r;++s)if(!A.z(a,b[s],d,e[s],f,!1))return!1
return!0},
jN(a,b,c,d,e,f){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.z(a,r[s],c,q[s],e,!1))return!1
return!0},
c6(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.ar(a))if(s!==7)if(!(s===6&&A.c6(a.x)))r=s===8&&A.c6(a.x)
return r},
ko(a){var s
if(!A.ar(a))s=a===t.c
else s=!0
return s},
ar(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.cK},
hO(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
fb(a){return a>0?new Array(a):v.typeUniverse.sEA},
V:function V(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
cQ:function cQ(){this.c=this.b=this.a=null},
cV:function cV(a){this.a=a},
cO:function cO(){},
bX:function bX(a){this.a=a},
j5(){var s,r,q
if(self.scheduleImmediate!=null)return A.k4()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.ff(new A.eT(s),1)).observe(r,{childList:true})
return new A.eS(s,r,q)}else if(self.setImmediate!=null)return A.k5()
return A.k6()},
j6(a){self.scheduleImmediate(A.ff(new A.eU(t.M.a(a)),0))},
j7(a){self.setImmediate(A.ff(new A.eV(t.M.a(a)),0))},
j8(a){t.M.a(a)
A.ji(0,a)},
ji(a,b){var s=new A.f9()
s.by(a,b)
return s},
fy(a){var s
if(t.Q.b(a)){s=a.gal()
if(s!=null)return s}return B.v},
j9(a,b,c){var s,r,q,p={},o=p.a=a
for(s=t.d;r=o.a,(r&4)!==0;o=a){a=s.a(o.c)
p.a=a}if(o===b){b.bF(new A.a6(!0,o,null,"Cannot complete a future with itself"),A.j_())
return}s=r|b.a&1
o.a=s
if((s&24)===0){q=t.F.a(b.c)
b.a=b.a&1|4
b.c=o
o.bd(q)
return}q=b.ao()
b.am(p.a)
A.b4(b,q)
return},
b4(a,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c={},b=c.a=a
for(s=t.n,r=t.F,q=t.b9;!0;){p={}
o=b.a
n=(o&16)===0
m=!n
if(a0==null){if(m&&(o&1)===0){l=s.a(b.c)
A.fd(l.a,l.b)}return}p.a=a0
k=a0.a
for(b=a0;k!=null;b=k,k=j){b.a=null
A.b4(c.a,b)
p.a=k
j=k.a}o=c.a
i=o.c
p.b=m
p.c=i
if(n){h=b.c
h=(h&1)!==0||(h&15)===8}else h=!0
if(h){g=b.b.b
if(m){o=o.b===g
o=!(o||o)}else o=!1
if(o){s.a(i)
A.fd(i.a,i.b)
return}f=$.E
if(f!==g)$.E=g
else f=null
b=b.c
if((b&15)===8)new A.f2(p,c,m).$0()
else if(n){if((b&1)!==0)new A.f1(p,i).$0()}else if((b&2)!==0)new A.f0(c,p).$0()
if(f!=null)$.E=f
b=p.c
if(b instanceof A.X){o=p.a.$ti
o=o.i("bj<2>").b(b)||!o.y[1].b(b)}else o=!1
if(o){q.a(b)
e=p.a.b
if((b.a&24)!==0){d=r.a(e.c)
e.c=null
a0=e.ap(d)
e.a=b.a&30|e.a&1
e.c=b.c
c.a=b
continue}else A.j9(b,e,!0)
return}}e=p.a.b
d=r.a(e.c)
e.c=null
a0=e.ap(d)
b=p.b
o=p.c
if(!b){e.$ti.c.a(o)
e.a=8
e.c=o}else{s.a(o)
e.a=e.a&1|16
e.c=o}c.a=e
b=e}},
jV(a,b){var s=t.C
if(s.b(a))return s.a(a)
s=t.v
if(s.b(a))return s.a(a)
throw A.c(A.h4(a,"onError",u.c))},
jT(){var s,r
for(s=$.b6;s!=null;s=$.b6){$.c3=null
r=s.b
$.b6=r
if(r==null)$.c2=null
s.a.$0()}},
jY(){$.fQ=!0
try{A.jT()}finally{$.c3=null
$.fQ=!1
if($.b6!=null)$.h1().$1(A.i1())}},
hZ(a){var s=new A.cL(a),r=$.c2
if(r==null){$.b6=$.c2=s
if(!$.fQ)$.h1().$1(A.i1())}else $.c2=r.b=s},
jX(a){var s,r,q,p=$.b6
if(p==null){A.hZ(a)
$.c3=$.c2
return}s=new A.cL(a)
r=$.c3
if(r==null){s.b=p
$.b6=$.c3=s}else{q=r.b
s.b=q
$.c3=r.b=s
if(q==null)$.c2=s}},
fd(a,b){A.jX(new A.fe(a,b))},
hW(a,b,c,d,e){var s,r=$.E
if(r===c)return d.$0()
$.E=c
s=r
try{r=d.$0()
return r}finally{$.E=s}},
hX(a,b,c,d,e,f,g){var s,r=$.E
if(r===c)return d.$1(e)
$.E=c
s=r
try{r=d.$1(e)
return r}finally{$.E=s}},
jW(a,b,c,d,e,f,g,h,i){var s,r=$.E
if(r===c)return d.$2(e,f)
$.E=c
s=r
try{r=d.$2(e,f)
return r}finally{$.E=s}},
fR(a,b,c,d){t.M.a(d)
if(B.e!==c)d=c.c8(d)
A.hZ(d)},
eT:function eT(a){this.a=a},
eS:function eS(a,b,c){this.a=a
this.b=b
this.c=c},
eU:function eU(a){this.a=a},
eV:function eV(a){this.a=a},
f9:function f9(){},
fa:function fa(a,b){this.a=a
this.b=b},
at:function at(a,b){this.a=a
this.b=b},
bK:function bK(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
X:function X(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
eY:function eY(a,b){this.a=a
this.b=b},
f_:function f_(a,b){this.a=a
this.b=b},
eZ:function eZ(a,b,c){this.a=a
this.b=b
this.c=c},
f2:function f2(a,b,c){this.a=a
this.b=b
this.c=c},
f3:function f3(a,b){this.a=a
this.b=b},
f4:function f4(a){this.a=a},
f1:function f1(a,b){this.a=a
this.b=b},
f0:function f0(a,b){this.a=a
this.b=b},
cL:function cL(a){this.a=a
this.b=null},
bE:function bE(){},
eL:function eL(a,b){this.a=a
this.b=b},
eM:function eM(a,b){this.a=a
this.b=b},
c1:function c1(){},
fe:function fe(a,b){this.a=a
this.b=b},
cT:function cT(){},
f7:function f7(a,b){this.a=a
this.b=b},
f8:function f8(a,b,c){this.a=a
this.b=b
this.c=c},
ha(a,b){return new A.bL(a.i("@<0>").a_(b).i("bL<1,2>"))},
fH(a,b){var s=a[b]
return s===a?null:s},
fI(a,b,c){if(c==null)a[b]=a
else a[b]=c},
hC(){var s=Object.create(null)
A.fI(s,"<non-identifier-key>",s)
delete s["<non-identifier-key>"]
return s},
iP(a,b,c){return b.i("@<0>").a_(c).i("hh<1,2>").a(A.kf(a,new A.aJ(b.i("@<0>").a_(c).i("aJ<1,2>"))))},
H(a,b){return new A.aJ(a.i("@<0>").a_(b).i("aJ<1,2>"))},
hi(a){return new A.bO(a.i("bO<0>"))},
fJ(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
ja(a,b,c){var s=new A.aL(a,b,c.i("aL<0>"))
s.c=a.e
return s},
fE(a){var s,r
if(A.fX(a))return"{...}"
s=new A.cG("")
try{r={}
B.a.h($.T,a)
s.a+="{"
r.a=!0
a.au(0,new A.ds(r,s))
s.a+="}"}finally{if(0>=$.T.length)return A.e($.T,-1)
$.T.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
fD(a){return new A.bs(A.bt(A.iQ(null),null,!1,a.i("0?")),a.i("bs<0>"))},
iQ(a){return 8},
bL:function bL(a){var _=this
_.a=0
_.e=_.d=_.c=_.b=null
_.$ti=a},
bM:function bM(a,b){this.a=a
this.$ti=b},
bN:function bN(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bO:function bO(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
cS:function cS(a){this.a=a
this.b=null},
aL:function aL(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
u:function u(){},
aV:function aV(){},
ds:function ds(a,b){this.a=a
this.b=b},
bs:function bs(a,b){var _=this
_.a=a
_.d=_.c=_.b=0
_.$ti=b},
bP:function bP(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=null
_.$ti=e},
aZ:function aZ(){},
bV:function bV(){},
kd(a){var s=A.ho(a)
if(s!=null)return s
throw A.c(new A.df("Invalid double",a))},
iC(a,b){a=A.c(a)
if(a==null)a=t.K.a(a)
a.stack=b.n(0)
throw a
throw A.c("unreachable")},
bt(a,b,c,d){var s,r=J.he(a,d)
if(a!==0&&b!=null)for(s=0;s<a;++s)r[s]=b
return r},
iS(a,b,c){var s,r=A.d([],c.i("t<0>"))
for(s=J.ba(a);s.C();)B.a.h(r,c.a(s.gG()))
r.$flags=1
return r},
a9(a,b,c){var s=A.iR(a,c)
return s},
iR(a,b){var s,r
if(Array.isArray(a))return A.d(a.slice(0),b.i("t<0>"))
s=A.d([],b.i("t<0>"))
for(r=J.ba(a);r.C();)B.a.h(s,r.gG())
return s},
iT(a,b,c,d){var s,r=J.he(a,d)
for(s=0;s<a;++s)B.a.l(r,s,b.$1(s))
return r},
hj(a,b){var s=A.iS(a,!1,b)
s.$flags=3
return s},
hv(a,b,c){var s=J.ba(b)
if(!s.C())return a
if(c.length===0){do a+=A.p(s.gG())
while(s.C())}else{a+=A.p(s.gG())
for(;s.C();)a=a+c+A.p(s.gG())}return a},
j_(){return A.aF(new Error())},
ch(a){if(typeof a=="number"||A.fP(a)||a==null)return J.c8(a)
if(typeof a=="string")return JSON.stringify(a)
return A.hp(a)},
iD(a,b){A.fT(a,"error",t.K)
A.fT(b,"stackTrace",t.l)
A.iC(a,b)},
ca(a){return new A.be(a)},
bc(a,b){return new A.a6(!1,null,b,a)},
h4(a,b,c){return new A.a6(!0,a,b,c)},
hq(a){var s=null
return new A.aX(s,s,!1,s,s,a)},
aY(a,b,c,d,e){return new A.aX(b,c,!0,a,d,"Invalid value")},
hr(a,b,c){if(0>a||a>c)throw A.c(A.aY(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.c(A.aY(b,a,c,"end",null))
return b}return c},
dD(a,b){if(a<0)throw A.c(A.aY(a,0,null,b,null))
return a},
dk(a,b,c,d,e){return new A.cj(b,!0,a,e,"Index out of range")},
b3(a){return new A.bG(a)},
hz(a){return new A.cI(a)},
b1(a){return new A.b0(a)},
ac(a){return new A.cd(a)},
hc(a,b,c){var s,r
if(A.fX(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.d([],t.U)
B.a.h($.T,a)
try{A.jR(a,s)}finally{if(0>=$.T.length)return A.e($.T,-1)
$.T.pop()}r=A.hv(b,t.hf.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
dl(a,b,c){var s,r
if(A.fX(a))return b+"..."+c
s=new A.cG(b)
B.a.h($.T,a)
try{r=s
r.a=A.hv(r.a,a,", ")}finally{if(0>=$.T.length)return A.e($.T,-1)
$.T.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
jR(a,b){var s,r,q,p,o,n,m,l=a.gU(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.C())return
s=A.p(l.gG())
B.a.h(b,s)
k+=s.length+2;++j}if(!l.C()){if(j<=5)return
if(0>=b.length)return A.e(b,-1)
r=b.pop()
if(0>=b.length)return A.e(b,-1)
q=b.pop()}else{p=l.gG();++j
if(!l.C()){if(j<=4){B.a.h(b,A.p(p))
return}r=A.p(p)
if(0>=b.length)return A.e(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gG();++j
for(;l.C();p=o,o=n){n=l.gG();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
if(0>=b.length)return A.e(b,-1)
k-=b.pop().length+2;--j}B.a.h(b,"...")
return}}q=A.p(p)
r=A.p(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.e(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.a.h(b,m)
B.a.h(b,q)
B.a.h(b,r)},
hk(a,b,c,d){var s
if(B.f===c)return A.hw(B.b.gB(a),J.Y(b),$.cZ())
if(B.f===d){s=B.b.gB(a)
b=J.Y(b)
c=J.Y(c)
return A.eO(A.ai(A.ai(A.ai($.cZ(),s),b),c))}s=B.b.gB(a)
b=J.Y(b)
c=J.Y(c)
d=J.Y(d)
d=A.eO(A.ai(A.ai(A.ai(A.ai($.cZ(),s),b),c),d))
return d},
hl(a){var s,r,q=$.cZ()
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.l)(a),++r)q=A.ai(q,J.Y(a[r]))
return A.eO(q)},
cg:function cg(a){this.a=a},
o:function o(){},
be:function be(a){this.a=a},
aj:function aj(){},
a6:function a6(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
aX:function aX(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
cj:function cj(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bG:function bG(a){this.a=a},
cI:function cI(a){this.a=a},
b0:function b0(a){this.a=a},
cd:function cd(a){this.a=a},
cz:function cz(){},
bD:function bD(){},
eX:function eX(a){this.a=a},
df:function df(a,b){this.a=a
this.b=b},
h:function h(){},
L:function L(){},
n:function n(){},
cU:function cU(){},
eK:function eK(){this.b=this.a=0},
cG:function cG(a){this.a=a},
cR:function cR(){},
I:function I(a,b,c){this.a=a
this.b=b
this.$ti=c},
a8(a,b){var s=A.bt(7,null,!1,b.i("0?"))
return new A.bk(a,s,b.i("bk<0>"))},
bk:function bk(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=0
_.$ti=c},
Z:function Z(a,b){this.a=a
this.b=b},
aQ:function aQ(a,b,c){this.a=a
this.b=b
this.d=c},
a_:function a_(a,b){this.a=a
this.b=b},
ce:function ce(){},
bh:function bh(a){this.a=a},
bi:function bi(a){this.a=a},
ci:function ci(a,b){this.a=a
this.b=b},
dq(a,b,c,d,e,f){var s=new A.ad(b,f,c,d,e)
s.f=new A.aQ(new A.a(new Float64Array(2)),c*0.5,0.25)
s.r=null
s.w=new A.bh(b)
return s},
ad:function ad(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.w=_.r=_.f=$},
fF(a,b,c){var s=new Float64Array(2),r=new Float64Array(2),q=new Float64Array(2),p=new Float64Array(2),o=new Float64Array(2),n=new Float64Array(2)
return new A.af(c,b,a,new A.a(s),new A.a(r),new A.a(q),new A.a(p),new A.a(o),new A.a(n),new A.a(new Float64Array(2)))},
af:function af(a,b,c,d,e,f,g,h,i,j){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j},
bC:function bC(a,b){this.a=a
this.b=b},
a0:function a0(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=c},
cD:function cD(a){this.a=a},
aK:function aK(a){this.a=a},
a1:function a1(a,b){this.a=a
this.b=b},
eR(a,b,c,d){var s,r,q=A.d([],t.e)
if(b>0){s=new A.a(new Float64Array(2))
s.m(b,0)
B.a.h(q,s)
s=b*0.70710678118
r=new A.a(new Float64Array(2))
r.m(s,s)
B.a.h(q,r)
r=new A.a(new Float64Array(2))
r.m(s,-b*0.70710678118)
B.a.h(q,r)}return new A.al(d,a,b,c,q)},
al:function al(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
an(a,b,c){var s=new Float64Array(2),r=new Float64Array(2),q=new Float64Array(2),p=new Float64Array(2),o=new Float64Array(2)
s=new A.am(b,c,a,B.d,new A.a(s),new A.a(r),new A.a(q),new A.a(p),new A.a(o))
s.e=B.d.K()*2*3.141592653589793
return s},
am:function am(a,b,c,d,e,f,g,h,i){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=0
_.f=e
_.r=f
_.w=g
_.x=h
_.y=i},
iF(a,b,c,d){var s,r,q,p,o=b*d,n=J.hd(o,t.h)
for(s=0;s<o;++s){r=new Float64Array(2)
q=new A.a(r)
r[0]=1
r[1]=0
r=q
q=new Float64Array(2)
p=r.a
q[1]=p[1]
q[0]=p[0]
n[s]=new A.a(q)}return new A.de(c,a,b,d,n)},
de:function de(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
aH:function aH(a,b){this.a=a
this.b=b},
az:function az(a,b){this.a=a
this.b=b},
ah:function ah(a,b){this.a=a
this.b=b},
hm(a,b,c){var s=A.F(b)
return new A.dw(A.hj(new A.bw(b,s.i("@(1)").a(new A.dy()),s.i("bw<1,@>")),t.h),c,!1)},
dw:function dw(a,b,c){this.a=a
this.b=b
this.c=c},
dy:function dy(){},
c9:function c9(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d_:function d_(){},
d0:function d0(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d1:function d1(){},
dc:function dc(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d2:function d2(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d3:function d3(){},
d4:function d4(){},
d5:function d5(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d6:function d6(){},
d7:function d7(){},
d8:function d8(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d9:function d9(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
da:function da(a){this.a=a},
db:function db(a){this.a=a},
cf:function cf(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dd:function dd(){},
dj:function dj(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dn:function dn(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dp:function dp(){},
du:function du(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dv:function dv(){},
dh(a,b){var s=new A.dg(a,b)
s.bx(a,b,1,null)
return s},
dg:function dg(a,b){var _=this
_.a=a
_.b=b
_.c=$
_.d=0},
di:function di(a,b,c){this.a=a
this.b=b
this.c=c},
x:function x(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=null
_.r=_.f=0
_.x=_.w=!1
_.y=-1},
ag(a){var s,r,q=A.d([],t._)
for(s=a;s!=null;){B.a.h(q,s)
s=s.e}r=t.V
return A.a9(new A.S(q,r),!0,r.i("v.E"))},
dx:function dx(){},
q:function q(){},
eI:function eI(a,b){this.a=a
this.b=b},
eJ:function eJ(a){this.a=a},
D:function D(a,b){this.a=a
this.b=b},
hu(a){var s=t.S
s=new A.dF(a,A.ha(s,t.cH),A.ha(t.E,s))
s.b=1/a
return s},
dF:function dF(a,b,c){var _=this
_.a=a
_.b=$
_.c=b
_.d=c},
dG:function dG(){},
dH:function dH(){},
a:function a(a){this.a=a},
aA(a,b,c,d,e){var s=A.k2(new A.eW(c),t.m)
s=s==null?null:A.fc(s)
if(s!=null)a.addEventListener(b,s,!1)
return new A.cP(a,b,s,!1,e.i("cP<0>"))},
k2(a,b){var s=$.E
if(s===B.e)return a
return s.c9(a,b)},
fz:function fz(a,b){this.a=a
this.$ti=b},
bJ:function bJ(){},
cN:function cN(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
cP:function cP(a,b,c,d,e){var _=this
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
eW:function eW(a){this.a=a},
kc(){var s=A.dh(18,18),r=t.D
s.p(3,3).c=!1
s.p(3,4).c=!1
s.p(3,5).c=!1
s.p(4,5).c=!1
s.p(5,5).c=!1
s.p(6,5).c=!1
s.p(6,4).c=!1
s.p(6,3).c=!1
return new A.ay(s,new A.I(1,1,r),new A.I(16,16,r))},
k9(){var s,r,q,p,o,n=A.dh(35,35),m=t.D
for(s=1;s<34;++s)for(r=1;r<34;++r)n.p(s,r).c=!1
q=1+2*B.d.a3(16)
p=1+2*B.d.a3(16)
n.p(q,p).c=!0
new A.fg(B.d,35,35,n).$2(q,p)
for(o=0;o<100;++o)n.p(1+B.d.a3(33),1+B.d.a3(33)).c=!0
for(o=0;o<35;++o){n.p(o,0).c=!1
n.p(o,34).c=!1}for(o=1;o<34;++o){n.p(0,o).c=!1
n.p(34,o).c=!1}return new A.ay(n,new A.I(1,1,m),new A.I(33,33,m))},
ka(){var s,r,q,p,o,n,m,l,k,j=A.dh(30,30)
for(s=0;s<30;++s)for(r=0;r<30;++r)if(B.d.K()<0.33)j.p(r,s).c=!1
q=t.D
do{p=B.d.a3(30)
o=B.d.a3(30)
n=new A.I(p,o,q)}while(!j.k(p,o))
do{m=B.d.a3(30)
l=B.d.a3(30)
k=new A.I(m,l,q)}while(!j.k(m,l)||k.H(0,n))
j.p(p,o).c=!0
j.p(m,l).c=!0
return new A.ay(j,n,k)},
kg(a,b){var s,r,q,p,o,n,m,l,k,j,i=new A.eK()
$.h0()
n=$.dC.$0()
i.a=n
i.b=null
s=null
r=a.a
q=a.b
p=a.c
switch(b){case"AStarFinder":s=new A.c9(!0,!0,A.a3(),1)
break
case"BreadthFirstFinder":s=new A.dc(!0,!0,A.a3(),1)
break
case"DijkstraFinder":s=new A.cf(!0,!0,A.a3(),1)
break
case"JumpPointFinder":s=new A.dn(!0,!1,A.kj(),1)
break
case"IDAStarFinder":s=new A.dj(!0,!0,A.a3(),1)
break
case"OrthogonalJumpPointFinder":s=new A.du(!1,!1,A.a3(),1)
break
case"BiBreadthFirstFinder":s=new A.d8(!0,!0,A.a3(),1)
break
case"BiDijkstraFinder":s=new A.d9(!0,!0,A.a3(),1)
break
case"BestFirstFinder":s=new A.d0(!0,!0,A.a3(),1)
break
case"BiAStarFinder":s=new A.d2(!0,!0,A.a3(),1)
break
case"BiBestFirstFinder":s=new A.d5(!0,!0,A.a3(),1)
break
default:s=new A.c9(!0,!0,A.a3(),1)
b="AStarFinder (Defaulted)"}o=A.d([],t.eI)
try{o=s.W(q.a,q.b,p.a,p.b,r)}catch(m){}if(i.b==null)i.b=$.dC.$0()
n=o
l=A.F(n)
k=l.i("bu<1,I<b>>")
j=A.a9(new A.bu(new A.bH(n,l.i("aa(1)").a(new A.fj()),l.i("bH<1>")),l.i("I<b>(1)").a(new A.fk()),k),!0,k.i("h.E"))
return new A.cA(j,new A.cg(i.gcb()),b,j.length!==0,0)},
ky(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i=a2.a,h=a2.b,g=a2.c,f=i.a,e=i.b,d=t.m,c=A.P(d.a(a1.canvas).width),b=A.P(d.a(a1.canvas).height),a=c/f,a0=b/e
a1.clearRect(0,0,c,b)
for(d=t.D,s=0;r=s<e,r;++s)for(q=s*a0,p=0;o=p<f,o;++p){n=new A.I(p,s,d)
if(n.H(0,h))a1.fillStyle="#0f0"
else if(n.H(0,g))a1.fillStyle="#f00"
else{m=!1
if(o)o=r
else o=m
if(o){o=i.c
o===$&&A.f()
if(!(s<o.length))return A.e(o,s)
o=o[s]
if(!(p<o.length))return A.e(o,p)
o=o[p].c}else o=!1
if(!o)a1.fillStyle="#555"
else a1.fillStyle="#fff"}o=p*a
a1.fillRect(o,q,a,a0)
a1.strokeStyle="#eee"
a1.strokeRect(o,q,a,a0)}d=!1
if(a4!=null)if(a4.d){d=a4.a
d=d!==(a3==null?null:a3.a)}if(d){a1.strokeStyle="#888"
a1.lineWidth=Math.max(1,a/5)
a1.beginPath()
for(d=a4.a,l=0;l<d.length;++l){n=d[l]
k=(n.a+0.5)*a
j=(n.b+0.5)*a0
if(l===0)a1.moveTo(k,j)
else a1.lineTo(k,j)}a1.stroke()}if(a3!=null&&a3.d){a1.strokeStyle="#00f"
a1.lineWidth=Math.max(1,a/4)
a1.beginPath()
for(d=a3.a,l=0;l<d.length;++l){n=d[l]
k=(n.a+0.5)*a
j=(n.b+0.5)*a0
if(l===0)a1.moveTo(k,j)
else a1.lineTo(k,j)}a1.stroke()
a1.lineWidth=1}},
fZ(a,b,c){var s,r,q,p={},o=self,n=t.m,m="#"+a,l=t.z,k=l.a(n.a(o.document).querySelector(m+"Canvas")),j=l.a(n.a(o.document).querySelector(m+"-algo-select")),i=l.a(n.a(o.document).querySelector(m+"-results pre")),h=l.a(n.a(o.document).querySelector("#reload-maze-scenario")),g=l.a(n.a(o.document).querySelector("#reload-random-scenario")),f=l.a(n.a(o.document).querySelector(m+"-previous-algo"))
if(k==null||j==null||i==null||f==null)return
s=l.a(k.getContext("2d"))
r=b.$0()
p.a=r
$.ib.l(0,a,r)
$.fr.l(0,a,null)
p.b=null
o=new A.fv(p,a,j,i,f,s)
if(j!=null){n=t.a
A.aA(j,"change",n.i("~(1)?").a(new A.fs(o)),!1,n.c)}if(c){q=a==="maze"?h:g
if(q!=null){n=t.a
A.aA(q,"click",n.i("~(1)?").a(new A.ft(new A.fu(p,b,a,f,o))),!1,n.c)}}o.$0()},
ay:function ay(a,b,c){this.a=a
this.b=b
this.c=c},
fg:function fg(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
cA:function cA(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
fj:function fj(){},
fk:function fk(){},
fv:function fv(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
fs:function fs(a){this.a=a},
fu:function fu(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
ft:function ft(a){this.a=a},
C(a,b,c,d,e){var s=new A.a7(a,d,new A.a(new Float64Array(2)),c,b,e,A.H(t.dd,t.h5))
s.x=new A.eI(s,A.d([],t.cT))
return s},
kz(){A.P(t.m.a(self.window).requestAnimationFrame(A.fc(new A.fw())))},
a7:function a7(a,b,c,d,e,f,g){var _=this
_.a=a
_.b="blue"
_.c=b
_.d=c
_.e=d
_.f=e
_.r=1
_.w=f
_.x=$
_.y=g},
r:function r(a,b,c){this.d=a
this.a=b
this.b=c},
dI:function dI(a,b,c,d){var _=this
_.x=_.w=_.r=_.f=_.e=_.d=_.c=_.b=_.a=$
_.y=a
_.z=b
_.ay=_.ax=_.at=_.as=_.Q=null
_.ch=c
_.CW=null
_.cx=d
_.cy="Seek"
_.db=0},
dL:function dL(a){this.a=a},
dM:function dM(a){this.a=a},
dN:function dN(a){this.a=a},
dO:function dO(a){this.a=a},
dP:function dP(a){this.a=a},
ec:function ec(a){this.a=a},
ed:function ed(a){this.a=a},
ee:function ee(a){this.a=a},
ep:function ep(a){this.a=a},
eF:function eF(){},
eG:function eG(){},
eH:function eH(a,b){this.a=a
this.b=b},
ey:function ey(a){this.a=a},
ez:function ez(a,b){this.a=a
this.b=b},
e4:function e4(a){this.a=a},
eA:function eA(a,b){this.a=a
this.b=b},
e2:function e2(a){this.a=a},
eB:function eB(a,b){this.a=a
this.b=b},
e1:function e1(a){this.a=a},
eC:function eC(a,b){this.a=a
this.b=b},
e0:function e0(a){this.a=a},
eD:function eD(a,b){this.a=a
this.b=b},
e_:function e_(a){this.a=a},
eE:function eE(a){this.a=a},
ef:function ef(a){this.a=a},
eg:function eg(a,b){this.a=a
this.b=b},
dZ:function dZ(a){this.a=a},
eh:function eh(a,b){this.a=a
this.b=b},
dY:function dY(a){this.a=a},
ei:function ei(a,b,c){this.a=a
this.b=b
this.c=c},
dX:function dX(a){this.a=a},
ej:function ej(a,b,c){this.a=a
this.b=b
this.c=c},
dW:function dW(a,b){this.a=a
this.b=b},
ek:function ek(a,b){this.a=a
this.b=b},
dV:function dV(a){this.a=a},
el:function el(a,b){this.a=a
this.b=b},
dU:function dU(a){this.a=a},
em:function em(a,b){this.a=a
this.b=b},
eb:function eb(a){this.a=a},
en:function en(a,b){this.a=a
this.b=b},
ea:function ea(a){this.a=a},
eo:function eo(a,b){this.a=a
this.b=b},
e9:function e9(a){this.a=a},
eq:function eq(a,b){this.a=a
this.b=b},
e8:function e8(a,b){this.a=a
this.b=b},
er:function er(a,b){this.a=a
this.b=b},
e7:function e7(a,b){this.a=a
this.b=b},
es:function es(a,b){this.a=a
this.b=b},
e6:function e6(a,b){this.a=a
this.b=b},
et:function et(a,b){this.a=a
this.b=b},
e5:function e5(a,b){this.a=a
this.b=b},
eu:function eu(a,b){this.a=a
this.b=b},
e3:function e3(a,b){this.a=a
this.b=b},
ev:function ev(a,b){this.a=a
this.b=b},
dT:function dT(a,b){this.a=a
this.b=b},
ew:function ew(a,b){this.a=a
this.b=b},
dS:function dS(a,b){this.a=a
this.b=b},
ex:function ex(a,b){this.a=a
this.b=b},
dR:function dR(a,b){this.a=a
this.b=b},
dJ:function dJ(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dQ:function dQ(a){this.a=a},
dK:function dK(a){this.a=a},
fw:function fw(){},
kw(a){if(typeof dartPrint=="function"){dartPrint(a)
return}if(typeof console=="object"&&typeof console.log!="undefined"){console.log(a)
return}if(typeof print=="function"){print(a)
return}throw"Unable to print message: "+String(a)},
kA(a){A.fx(new A.aU("Field '"+a+"' has been assigned during initialization."),new Error())},
f(){A.fx(new A.aU("Field '' has not been initialized."),new Error())},
kB(){A.fx(new A.aU("Field '' has already been initialized."),new Error())},
fc(a){var s
if(typeof a=="function")throw A.c(A.bc("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.jy,a)
s[$.h_()]=a
return s},
jy(a,b,c){t.Y.a(a)
if(A.P(c)>=1)return a.$1(b)
return a.$0()},
k7(a,b,c,d){return d.a(a[b].apply(a,c))},
iH(a,b){return Math.abs(A.P(a))+Math.abs(A.P(b))},
iI(a,b){var s=Math.abs(A.P(a)),r=Math.abs(A.P(b))
return Math.max(s,r)+0.4142135623730949*Math.min(s,r)},
j4(a,b){var s
if(b<=0){a.ai()
return}s=a.gt()
if(s>b*b)a.A(b/Math.sqrt(s))},
kq(){var s=self,r=t.m,q=t.z
if(q.a(r.a(s.document).querySelector("#pathfinding-scenario-container"))!=null){A.fZ("simple",A.kv(),!1)
A.fZ("maze",A.kt(),!0)
A.fZ("random",A.ku(),!0)}else if(q.a(r.a(s.document).querySelector("#steeringCanvas"))!=null)A.kz()}},B={}
var w=[A,J,B]
var $={}
A.fB.prototype={}
J.ck.prototype={
H(a,b){return a===b},
gB(a){return A.cC(a)},
n(a){return"Instance of '"+A.dA(a)+"'"},
gL(a){return A.ab(A.fO(this))}}
J.cl.prototype={
n(a){return String(a)},
gB(a){return a?519018:218159},
gL(a){return A.ab(t.y)},
$im:1,
$iaa:1}
J.bm.prototype={
H(a,b){return null==b},
n(a){return"null"},
gB(a){return 0},
$im:1}
J.bo.prototype={$iy:1}
J.ax.prototype={
gB(a){return 0},
n(a){return String(a)}}
J.cB.prototype={}
J.b2.prototype={}
J.aw.prototype={
n(a){var s=a[$.h_()]
if(s==null)return this.bw(a)
return"JavaScript function for "+J.c8(s)},
$iaI:1}
J.bn.prototype={
gB(a){return 0},
n(a){return String(a)}}
J.bp.prototype={
gB(a){return 0},
n(a){return String(a)}}
J.t.prototype={
h(a,b){A.F(a).c.a(b)
a.$flags&1&&A.A(a,29)
a.push(b)},
a4(a,b){var s
a.$flags&1&&A.A(a,"remove",1)
for(s=0;s<a.length;++s)if(J.U(a[s],b)){a.splice(s,1)
return!0}return!1},
bU(a,b,c){var s,r,q,p,o
A.F(a).i("aa(1)").a(b)
s=[]
r=a.length
for(q=0;q<r;++q){p=a[q]
if(!A.i2(b.$1(p)))s.push(p)
if(a.length!==r)throw A.c(A.ac(a))}o=s.length
if(o===r)return
this.sq(a,o)
for(q=0;q<s.length;++q)a[q]=s[q]},
aq(a,b){A.F(a).i("h<1>").a(b)
a.$flags&1&&A.A(a,"addAll",2)
this.bA(a,b)
return},
bA(a,b){var s,r
t.u.a(b)
s=b.length
if(s===0)return
if(a===b)throw A.c(A.ac(a))
for(r=0;r<s;++r)a.push(b[r])},
X(a){a.$flags&1&&A.A(a,"clear","clear")
a.length=0},
a2(a,b){if(!(b>=0&&b<a.length))return A.e(a,b)
return a[b]},
gY(a){if(a.length>0)return a[0]
throw A.c(A.hb())},
az(a,b,c,d,e){var s,r,q,p
A.F(a).i("h<1>").a(d)
a.$flags&2&&A.A(a,5)
A.hr(b,c,a.length)
s=c-b
if(s===0)return
A.dD(e,"skipCount")
r=d
q=J.cY(r)
if(e+s>q.gq(r))throw A.c(A.iM())
if(e<b)for(p=s-1;p>=0;--p)a[b+p]=q.j(r,e+p)
else for(p=0;p<s;++p)a[b+p]=q.j(r,e+p)},
aW(a,b,c,d){return this.az(a,b,c,d,0)},
bu(a,b){var s,r,q,p
a.$flags&2&&A.A(a,"shuffle")
s=a.length
for(;s>1;){r=b.a3(s);--s
q=a.length
if(!(s<q))return A.e(a,s)
p=a[s]
if(!(r>=0&&r<q))return A.e(a,r)
a[s]=a[r]
a[r]=p}},
aa(a,b){var s
for(s=0;s<a.length;++s)if(J.U(a[s],b))return!0
return!1},
gah(a){return a.length===0},
n(a){return A.dl(a,"[","]")},
gU(a){return new J.bd(a,a.length,A.F(a).i("bd<1>"))},
gB(a){return A.cC(a)},
gq(a){return a.length},
sq(a,b){a.$flags&1&&A.A(a,"set length","change the length of")
if(b>a.length)A.F(a).c.a(null)
a.length=b},
j(a,b){if(!(b>=0&&b<a.length))throw A.c(A.fh(a,b))
return a[b]},
l(a,b,c){A.F(a).c.a(c)
a.$flags&2&&A.A(a)
if(!(b>=0&&b<a.length))throw A.c(A.fh(a,b))
a[b]=c},
O(a,b){var s=A.F(a)
s.i("k<1>").a(b)
s=A.a9(a,!0,s.c)
this.aq(s,b)
return s},
$ih:1,
$ik:1}
J.dm.prototype={}
J.bd.prototype={
gG(){var s=this.d
return s==null?this.$ti.c.a(s):s},
C(){var s,r=this,q=r.a,p=q.length
if(r.b!==p){q=A.l(q)
throw A.c(q)}s=r.c
if(s>=p){r.sb7(null)
return!1}r.sb7(q[s]);++r.c
return!0},
sb7(a){this.d=this.$ti.i("1?").a(a)},
$iO:1}
J.aS.prototype={
S(a,b){var s
A.jt(b)
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gav(b)
if(this.gav(a)===s)return 0
if(this.gav(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gav(a){return a===0?1/a<0:a<0},
bl(a){var s,r
if(a>=0){if(a<=2147483647){s=a|0
return a===s?s:s+1}}else if(a>=-2147483648)return a|0
r=Math.ceil(a)
if(isFinite(r))return r
throw A.c(A.b3(""+a+".ceil()"))},
Z(a){var s,r
if(a>=0){if(a<=2147483647)return a|0}else if(a>=-2147483648){s=a|0
return a===s?s:s-1}r=Math.floor(a)
if(isFinite(r))return r
throw A.c(A.b3(""+a+".floor()"))},
a9(a,b,c){if(this.S(b,c)>0)throw A.c(A.i0(b))
if(this.S(a,b)<0)return b
if(this.S(a,c)>0)return c
return a},
bo(a,b){var s
if(b>20)throw A.c(A.aY(b,0,20,"fractionDigits",null))
s=a.toFixed(b)
if(a===0&&this.gav(a))return"-"+s
return s},
n(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gB(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
ac(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
if(b<0)return s-b
else return s+b},
V(a,b){return(a|0)===a?a/b|0:this.c6(a,b)},
c6(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.c(A.b3("Result of truncating division is "+A.p(s)+": "+A.p(a)+" ~/ "+b))},
c1(a,b){var s
if(a>0)s=this.c0(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
c0(a,b){return b>31?0:a>>>b},
gL(a){return A.ab(t.di)},
$ii:1,
$ib9:1}
J.bl.prototype={
gad(a){var s
if(a>0)s=1
else s=a<0?-1:a
return s},
gL(a){return A.ab(t.S)},
$im:1,
$ib:1}
J.cm.prototype={
gL(a){return A.ab(t.i)},
$im:1}
J.aT.prototype={
bv(a,b,c){return a.substring(b,A.hr(b,c,a.length))},
cn(a){var s,r,q,p=a.trim(),o=p.length
if(o===0)return p
if(0>=o)return A.e(p,0)
if(p.charCodeAt(0)===133){s=J.iN(p,1)
if(s===o)return""}else s=0
r=o-1
if(!(r>=0))return A.e(p,r)
q=p.charCodeAt(r)===133?J.iO(p,r):o
if(s===0&&q===o)return p
return p.substring(s,q)},
E(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.c(B.u)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
cg(a,b,c){var s=b-a.length
if(s<=0)return a
return this.E(c,s)+a},
n(a){return a},
gB(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gL(a){return A.ab(t.N)},
gq(a){return a.length},
$im:1,
$iW:1}
A.aU.prototype={
n(a){return"LateInitializationError: "+this.a}}
A.dE.prototype={}
A.bg.prototype={}
A.v.prototype={
gU(a){var s=this
return new A.R(s,s.gq(s),A.J(s).i("R<v.E>"))}}
A.bF.prototype={
gbL(){var s=J.aG(this.a),r=this.c
if(r==null||r>s)return s
return r},
gc3(){var s=J.aG(this.a),r=this.b
if(r>s)return s
return r},
gq(a){var s,r=J.aG(this.a),q=this.b
if(q>=r)return 0
s=this.c
if(s==null||s>=r)return r-q
if(typeof s!=="number")return s.u()
return s-q},
a2(a,b){var s=this,r=s.gc3()+b
if(b<0||r>=s.gbL())throw A.c(A.dk(b,s.gq(0),s,null,"index"))
return J.h3(s.a,r)}}
A.R.prototype={
gG(){var s=this.d
return s==null?this.$ti.c.a(s):s},
C(){var s,r=this,q=r.a,p=J.cY(q),o=p.gq(q)
if(r.b!==o)throw A.c(A.ac(q))
s=r.c
if(s>=o){r.saj(null)
return!1}r.saj(p.a2(q,s));++r.c
return!0},
saj(a){this.d=this.$ti.i("1?").a(a)},
$iO:1}
A.bu.prototype={
gU(a){return new A.bv(J.ba(this.a),this.b,A.J(this).i("bv<1,2>"))},
gq(a){return J.aG(this.a)}}
A.bv.prototype={
C(){var s=this,r=s.b
if(r.C()){s.saj(s.c.$1(r.gG()))
return!0}s.saj(null)
return!1},
gG(){var s=this.a
return s==null?this.$ti.y[1].a(s):s},
saj(a){this.a=this.$ti.i("2?").a(a)},
$iO:1}
A.bw.prototype={
gq(a){return J.aG(this.a)},
a2(a,b){return this.b.$1(J.h3(this.a,b))}}
A.bH.prototype={
gU(a){return new A.bI(J.ba(this.a),this.b,this.$ti.i("bI<1>"))}}
A.bI.prototype={
C(){var s,r
for(s=this.a,r=this.b;s.C();)if(A.i2(r.$1(s.gG())))return!0
return!1},
gG(){return this.a.gG()},
$iO:1}
A.w.prototype={
sq(a,b){throw A.c(A.b3("Cannot change the length of a fixed-length list"))},
h(a,b){A.aO(a).i("w.E").a(b)
throw A.c(A.b3("Cannot add to a fixed-length list"))},
a4(a,b){throw A.c(A.b3("Cannot remove from a fixed-length list"))}}
A.S.prototype={
gq(a){return J.aG(this.a)},
a2(a,b){var s=this.a,r=J.cY(s)
return r.a2(s,r.gq(s)-1-b)}}
A.j.prototype={$r:"+(1,2)",$s:1}
A.G.prototype={$r:"+behavior,weight(1,2)",$s:2}
A.B.prototype={$r:"+description,interaction(1,2)",$s:3}
A.bU.prototype={$r:"+mass,maxForce,maxSpeed,radius(1,2,3,4)",$s:4}
A.bf.prototype={
n(a){return A.fE(this)},
$iae:1}
A.av.prototype={
gq(a){return this.b.length},
aK(a){if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
j(a,b){if(!this.aK(b))return null
return this.b[this.a[b]]},
au(a,b){var s,r,q,p,o=this
o.$ti.i("~(1,2)").a(b)
s=o.$keys
if(s==null){s=Object.keys(o.a)
o.$keys=s}s=s
r=o.b
for(q=s.length,p=0;p<q;++p)b.$2(s[p],r[p])}}
A.dz.prototype={
$0(){return B.c.Z(1000*this.a.now())},
$S:11}
A.eP.prototype={
a1(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.bB.prototype={
n(a){return"Null check operator used on a null value"}}
A.cn.prototype={
n(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.cJ.prototype={
n(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.dt.prototype={
n(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.bW.prototype={
n(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$ib_:1}
A.au.prototype={
n(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.ic(r==null?"unknown":r)+"'"},
$iaI:1,
gcp(){return this},
$C:"$1",
$R:1,
$D:null}
A.cb.prototype={$C:"$0",$R:0}
A.cc.prototype={$C:"$2",$R:2}
A.cH.prototype={}
A.cF.prototype={
n(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.ic(s)+"'"}}
A.aR.prototype={
H(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aR))return!1
return this.$_target===b.$_target&&this.a===b.a},
gB(a){return(A.i8(this.a)^A.cC(this.$_target))>>>0},
n(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.dA(this.a)+"'")}}
A.cM.prototype={
n(a){return"Reading static variable '"+this.a+"' during its initialization"}}
A.cE.prototype={
n(a){return"RuntimeError: "+this.a}}
A.cK.prototype={
n(a){return"Assertion failed: "+A.ch(this.a)}}
A.aJ.prototype={
gq(a){return this.a},
gaO(){return new A.br(this,A.J(this).i("br<1>"))},
j(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.cd(b)},
cd(a){var s,r,q=this.d
if(q==null)return null
s=q[this.aL(a)]
r=this.aM(s,a)
if(r<0)return null
return s[r].b},
l(a,b,c){var s,r,q,p,o,n,m=this,l=A.J(m)
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"){s=m.b
m.aX(s==null?m.b=m.aH():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=m.c
m.aX(r==null?m.c=m.aH():r,b,c)}else{q=m.d
if(q==null)q=m.d=m.aH()
p=m.aL(b)
o=q[p]
if(o==null)q[p]=[m.aA(b,c)]
else{n=m.aM(o,b)
if(n>=0)o[n].b=c
else o.push(m.aA(b,c))}}},
a4(a,b){var s=this.ce(b)
return s},
ce(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=o.aL(a)
r=n[s]
q=o.aM(r,a)
if(q<0)return null
p=r.splice(q,1)[0]
o.c7(p)
if(r.length===0)delete n[s]
return p.b},
X(a){var s=this
if(s.a>0){s.b=s.c=s.d=s.e=s.f=null
s.a=0
s.aG()}},
au(a,b){var s,r,q=this
A.J(q).i("~(1,2)").a(b)
s=q.e
r=q.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==q.r)throw A.c(A.ac(q))
s=s.c}},
aX(a,b,c){var s,r=A.J(this)
r.c.a(b)
r.y[1].a(c)
s=a[b]
if(s==null)a[b]=this.aA(b,c)
else s.b=c},
aG(){this.r=this.r+1&1073741823},
aA(a,b){var s=this,r=A.J(s),q=new A.dr(r.c.a(a),r.y[1].a(b))
if(s.e==null)s.e=s.f=q
else{r=s.f
r.toString
q.d=r
s.f=r.c=q}++s.a
s.aG()
return q},
c7(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.aG()},
aL(a){return J.Y(a)&1073741823},
aM(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.U(a[r].a,b))return r
return-1},
n(a){return A.fE(this)},
aH(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$ihh:1}
A.dr.prototype={}
A.br.prototype={
gq(a){return this.a.a},
gU(a){var s=this.a
return new A.bq(s,s.r,s.e,this.$ti.i("bq<1>"))}}
A.bq.prototype={
gG(){return this.d},
C(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.c(A.ac(q))
s=r.c
if(s==null){r.saY(null)
return!1}else{r.saY(s.a)
r.c=s.c
return!0}},
saY(a){this.d=this.$ti.i("1?").a(a)},
$iO:1}
A.fm.prototype={
$1(a){return this.a(a)},
$S:20}
A.fn.prototype={
$2(a,b){return this.a(a,b)},
$S:21}
A.fo.prototype={
$1(a){return this.a(A.aD(a))},
$S:27}
A.a2.prototype={
n(a){return this.bj(!1)},
bj(a){var s,r,q,p,o,n=this.bM(),m=this.aF(),l=(a?""+"Record ":"")+"("
for(s=n.length,r="",q=0;q<s;++q,r=", "){l+=r
p=n[q]
if(typeof p=="string")l=l+p+": "
if(!(q<m.length))return A.e(m,q)
o=m[q]
l=a?l+A.hp(o):l+A.p(o)}l+=")"
return l.charCodeAt(0)==0?l:l},
bM(){var s,r=this.$s
for(;$.f6.length<=r;)B.a.h($.f6,null)
s=$.f6[r]
if(s==null){s=this.bJ()
B.a.l($.f6,r,s)}return s},
bJ(){var s,r,q,p=this.$r,o=p.indexOf("("),n=p.substring(1,o),m=p.substring(o),l=m==="()"?0:m.replace(/[^,]/g,"").length+1,k=A.d(new Array(l),t.L)
for(s=0;s<l;++s)k[s]=s
if(n!==""){r=n.split(",")
s=r.length
for(q=l;s>0;){--q;--s
B.a.l(k,q,r[s])}}return A.hj(k,t.K)}}
A.aC.prototype={
aF(){return[this.a,this.b]},
H(a,b){if(b==null)return!1
return b instanceof A.aC&&this.$s===b.$s&&J.U(this.a,b.a)&&J.U(this.b,b.b)},
gB(a){return A.hk(this.$s,this.a,this.b,B.f)}}
A.b5.prototype={
aF(){return this.a},
H(a,b){if(b==null)return!1
return b instanceof A.b5&&this.$s===b.$s&&A.jh(this.a,b.a)},
gB(a){return A.hk(this.$s,A.hl(this.a),B.f,B.f)}}
A.co.prototype={
gL(a){return B.a_},
$im:1}
A.bz.prototype={}
A.cp.prototype={
gL(a){return B.a0},
$im:1}
A.aW.prototype={
gq(a){return a.length},
$iQ:1}
A.bx.prototype={
j(a,b){A.ap(b,a,a.length)
return a[b]},
l(a,b,c){A.aM(c)
a.$flags&2&&A.A(a)
A.ap(b,a,a.length)
a[b]=c},
$ih:1,
$ik:1}
A.by.prototype={
l(a,b,c){A.P(c)
a.$flags&2&&A.A(a)
A.ap(b,a,a.length)
a[b]=c},
$ih:1,
$ik:1}
A.cq.prototype={
gL(a){return B.a1},
$im:1}
A.cr.prototype={
gL(a){return B.a2},
$im:1,
$ifA:1}
A.cs.prototype={
gL(a){return B.a3},
j(a,b){A.ap(b,a,a.length)
return a[b]},
$im:1}
A.ct.prototype={
gL(a){return B.a4},
j(a,b){A.ap(b,a,a.length)
return a[b]},
$im:1}
A.cu.prototype={
gL(a){return B.a5},
j(a,b){A.ap(b,a,a.length)
return a[b]},
$im:1}
A.cv.prototype={
gL(a){return B.a7},
j(a,b){A.ap(b,a,a.length)
return a[b]},
$im:1}
A.cw.prototype={
gL(a){return B.a8},
j(a,b){A.ap(b,a,a.length)
return a[b]},
$im:1}
A.bA.prototype={
gL(a){return B.a9},
gq(a){return a.length},
j(a,b){A.ap(b,a,a.length)
return a[b]},
$im:1}
A.cx.prototype={
gL(a){return B.aa},
gq(a){return a.length},
j(a,b){A.ap(b,a,a.length)
return a[b]},
$im:1}
A.bQ.prototype={}
A.bR.prototype={}
A.bS.prototype={}
A.bT.prototype={}
A.V.prototype={
i(a){return A.c0(v.typeUniverse,this,a)},
a_(a){return A.hN(v.typeUniverse,this,a)}}
A.cQ.prototype={}
A.cV.prototype={
n(a){return A.K(this.a,null)},
$ihx:1}
A.cO.prototype={
n(a){return this.a}}
A.bX.prototype={$iaj:1}
A.eT.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:14}
A.eS.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:33}
A.eU.prototype={
$0(){this.a.$0()},
$S:13}
A.eV.prototype={
$0(){this.a.$0()},
$S:13}
A.f9.prototype={
by(a,b){if(self.setTimeout!=null)self.setTimeout(A.ff(new A.fa(this,b),0),a)
else throw A.c(A.b3("`setTimeout()` not found."))}}
A.fa.prototype={
$0(){this.b.$0()},
$S:1}
A.at.prototype={
n(a){return A.p(this.a)},
$io:1,
gal(){return this.b}}
A.bK.prototype={
cf(a){if((this.c&15)!==6)return!0
return this.b.b.aR(t.al.a(this.d),a.a,t.y,t.K)},
cc(a){var s,r=this,q=r.e,p=null,o=t.B,n=t.K,m=a.a,l=r.b.b
if(t.C.b(q))p=l.cj(q,m,a.b,o,n,t.l)
else p=l.aR(t.v.a(q),m,o,n)
try{o=r.$ti.i("2/").a(p)
return o}catch(s){if(t.eK.b(A.c7(s))){if((r.c&1)!==0)throw A.c(A.bc("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.c(A.bc("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.X.prototype={
cm(a,b,c){var s,r,q=this.$ti
q.a_(c).i("1/(2)").a(a)
s=$.E
if(s===B.e){if(!t.C.b(b)&&!t.v.b(b))throw A.c(A.h4(b,"onError",u.c))}else{c.i("@<0/>").a_(q.c).i("1(2)").a(a)
b=A.jV(b,s)}r=new A.X(s,c.i("X<0>"))
this.b_(new A.bK(r,3,a,b,q.i("@<1>").a_(c).i("bK<1,2>")))
return r},
bX(a){this.a=this.a&1|16
this.c=a},
am(a){this.a=a.a&30|this.a&1
this.c=a.c},
b_(a){var s,r=this,q=r.a
if(q<=3){a.a=t.F.a(r.c)
r.c=a}else{if((q&4)!==0){s=t.d.a(r.c)
if((s.a&24)===0){s.b_(a)
return}r.am(s)}A.fR(null,null,r.b,t.M.a(new A.eY(r,a)))}},
bd(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.F.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t.d.a(m.c)
if((n.a&24)===0){n.bd(a)
return}m.am(n)}l.a=m.ap(a)
A.fR(null,null,m.b,t.M.a(new A.f_(l,m)))}},
ao(){var s=t.F.a(this.c)
this.c=null
return this.ap(s)},
ap(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
bI(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.ao()
q.am(a)
A.b4(q,r)},
b5(a,b){var s
t.l.a(b)
s=this.ao()
this.bX(new A.at(a,b))
A.b4(this,s)},
bF(a,b){this.a^=2
A.fR(null,null,this.b,t.M.a(new A.eZ(this,a,b)))},
$ibj:1}
A.eY.prototype={
$0(){A.b4(this.a,this.b)},
$S:1}
A.f_.prototype={
$0(){A.b4(this.b,this.a.a)},
$S:1}
A.eZ.prototype={
$0(){this.a.b5(this.b,this.c)},
$S:1}
A.f2.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.ci(t.he.a(q.d),t.B)}catch(p){s=A.c7(p)
r=A.aF(p)
if(k.c&&t.n.a(k.b.a.c).a===s){q=k.a
q.c=t.n.a(k.b.a.c)}else{q=s
o=r
if(o==null)o=A.fy(q)
n=k.a
n.c=new A.at(q,o)
q=n}q.b=!0
return}if(j instanceof A.X&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=t.n.a(j.c)
q.b=!0}return}if(j instanceof A.X){m=k.b.a
l=new A.X(m.b,m.$ti)
j.cm(new A.f3(l,m),new A.f4(l),t.H)
q=k.a
q.c=l
q.b=!1}},
$S:1}
A.f3.prototype={
$1(a){this.a.bI(this.b)},
$S:14}
A.f4.prototype={
$2(a,b){this.a.b5(t.K.a(a),t.l.a(b))},
$S:22}
A.f1.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.aR(o.i("2/(1)").a(p.d),m,o.i("2/"),n)}catch(l){s=A.c7(l)
r=A.aF(l)
q=s
p=r
if(p==null)p=A.fy(q)
o=this.a
o.c=new A.at(q,p)
o.b=!0}},
$S:1}
A.f0.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=t.n.a(l.a.a.c)
p=l.b
if(p.a.cf(s)&&p.a.e!=null){p.c=p.a.cc(s)
p.b=!1}}catch(o){r=A.c7(o)
q=A.aF(o)
p=t.n.a(l.a.a.c)
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.fy(p)
m=l.b
m.c=new A.at(p,n)
p=m}p.b=!0}},
$S:1}
A.cL.prototype={}
A.bE.prototype={
gq(a){var s,r,q=this,p={},o=new A.X($.E,t.fJ)
p.a=0
s=q.$ti
r=s.i("~(1)?").a(new A.eL(p,q))
t.g5.a(new A.eM(p,o))
A.aA(q.a,q.b,r,!1,s.c)
return o}}
A.eL.prototype={
$1(a){this.b.$ti.c.a(a);++this.a.a},
$S(){return this.b.$ti.i("~(1)")}}
A.eM.prototype={
$0(){var s=this.b,r=s.$ti,q=r.i("1/").a(this.a.a),p=s.ao()
r.c.a(q)
s.a=8
s.c=q
A.b4(s,p)},
$S:1}
A.c1.prototype={$ihA:1}
A.fe.prototype={
$0(){A.iD(this.a,this.b)},
$S:1}
A.cT.prototype={
ck(a){var s,r,q
t.M.a(a)
try{if(B.e===$.E){a.$0()
return}A.hW(null,null,this,a,t.H)}catch(q){s=A.c7(q)
r=A.aF(q)
A.fd(t.K.a(s),t.l.a(r))}},
cl(a,b,c){var s,r,q
c.i("~(0)").a(a)
c.a(b)
try{if(B.e===$.E){a.$1(b)
return}A.hX(null,null,this,a,b,t.H,c)}catch(q){s=A.c7(q)
r=A.aF(q)
A.fd(t.K.a(s),t.l.a(r))}},
c8(a){return new A.f7(this,t.M.a(a))},
c9(a,b){return new A.f8(this,b.i("~(0)").a(a),b)},
ci(a,b){b.i("0()").a(a)
if($.E===B.e)return a.$0()
return A.hW(null,null,this,a,b)},
aR(a,b,c,d){c.i("@<0>").a_(d).i("1(2)").a(a)
d.a(b)
if($.E===B.e)return a.$1(b)
return A.hX(null,null,this,a,b,c,d)},
cj(a,b,c,d,e,f){d.i("@<0>").a_(e).a_(f).i("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.E===B.e)return a.$2(b,c)
return A.jW(null,null,this,a,b,c,d,e,f)}}
A.f7.prototype={
$0(){return this.a.ck(this.b)},
$S:1}
A.f8.prototype={
$1(a){var s=this.c
return this.a.cl(this.b,s.a(a),s)},
$S(){return this.c.i("~(0)")}}
A.bL.prototype={
gq(a){return this.a},
gaO(){return new A.bM(this,A.J(this).i("bM<1>"))},
aK(a){var s
if((a&1073741823)===a){s=this.c
return s==null?!1:s[a]!=null}else return this.bK(a)},
bK(a){var s=this.d
if(s==null)return!1
return this.ae(this.ba(s,a),a)>=0},
j(a,b){var s,r,q
if(typeof b=="string"&&b!=="__proto__"){s=this.b
r=s==null?null:A.fH(s,b)
return r}else if(typeof b=="number"&&(b&1073741823)===b){q=this.c
r=q==null?null:A.fH(q,b)
return r}else return this.bN(b)},
bN(a){var s,r,q=this.d
if(q==null)return null
s=this.ba(q,a)
r=this.ae(s,a)
return r<0?null:s[r+1]},
l(a,b,c){var s,r=this,q=A.J(r)
q.c.a(b)
q.y[1].a(c)
if(typeof b=="number"&&(b&1073741823)===b){s=r.c
r.bB(s==null?r.c=A.hC():s,b,c)}else r.bW(b,c)},
bW(a,b){var s,r,q,p,o=this,n=A.J(o)
n.c.a(a)
n.y[1].a(b)
s=o.d
if(s==null)s=o.d=A.hC()
r=o.aB(a)
q=s[r]
if(q==null){A.fI(s,r,[a,b]);++o.a
o.e=null}else{p=o.ae(q,a)
if(p>=0)q[p+1]=b
else{q.push(a,b);++o.a
o.e=null}}},
bn(a,b){var s,r,q=this,p=A.J(q)
p.c.a(a)
p.i("2()").a(b)
if(q.aK(a)){s=q.j(0,a)
return s==null?p.y[1].a(s):s}r=b.$0()
q.l(0,a,r)
return r},
a4(a,b){if((b&1073741823)===b)return this.bT(this.c,b)
else return this.bS(b)},
bS(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=o.aB(a)
r=n[s]
q=o.ae(r,a)
if(q<0)return null;--o.a
o.e=null
p=r.splice(q,2)[1]
if(0===r.length)delete n[s]
return p},
X(a){var s=this
if(s.a>0){s.b=s.c=s.d=s.e=null
s.a=0}},
au(a,b){var s,r,q,p,o,n,m=this,l=A.J(m)
l.i("~(1,2)").a(b)
s=m.b6()
for(r=s.length,q=l.c,l=l.y[1],p=0;p<r;++p){o=s[p]
q.a(o)
n=m.j(0,o)
b.$2(o,n==null?l.a(n):n)
if(s!==m.e)throw A.c(A.ac(m))}},
b6(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.e
if(h!=null)return h
h=A.bt(i.a,null,!1,t.B)
s=i.b
r=0
if(s!=null){q=Object.getOwnPropertyNames(s)
p=q.length
for(o=0;o<p;++o){h[r]=q[o];++r}}n=i.c
if(n!=null){q=Object.getOwnPropertyNames(n)
p=q.length
for(o=0;o<p;++o){h[r]=+q[o];++r}}m=i.d
if(m!=null){q=Object.getOwnPropertyNames(m)
p=q.length
for(o=0;o<p;++o){l=m[q[o]]
k=l.length
for(j=0;j<k;j+=2){h[r]=l[j];++r}}}return i.e=h},
bB(a,b,c){var s=A.J(this)
s.c.a(b)
s.y[1].a(c)
if(a[b]==null){++this.a
this.e=null}A.fI(a,b,c)},
bT(a,b){var s
if(a!=null&&a[b]!=null){s=A.J(this).y[1].a(A.fH(a,b))
delete a[b];--this.a
this.e=null
return s}else return null},
aB(a){return J.Y(a)&1073741823},
ba(a,b){return a[this.aB(b)]},
ae(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;r+=2)if(J.U(a[r],b))return r
return-1},
$iiG:1}
A.bM.prototype={
gq(a){return this.a.a},
gU(a){var s=this.a
return new A.bN(s,s.b6(),this.$ti.i("bN<1>"))}}
A.bN.prototype={
gG(){var s=this.d
return s==null?this.$ti.c.a(s):s},
C(){var s=this,r=s.b,q=s.c,p=s.a
if(r!==p.e)throw A.c(A.ac(p))
else if(q>=r.length){s.sa8(null)
return!1}else{s.sa8(r[q])
s.c=q+1
return!0}},
sa8(a){this.d=this.$ti.i("1?").a(a)},
$iO:1}
A.bO.prototype={
gU(a){var s=this,r=new A.aL(s,s.r,s.$ti.i("aL<1>"))
r.c=s.e
return r},
gq(a){return this.a},
h(a,b){var s,r,q=this
q.$ti.c.a(b)
if(typeof b=="string"&&b!=="__proto__"){s=q.b
return q.aZ(s==null?q.b=A.fJ():s,b)}else if(typeof b=="number"&&(b&1073741823)===b){r=q.c
return q.aZ(r==null?q.c=A.fJ():r,b)}else return q.a7(b)},
a7(a){var s,r,q,p=this
p.$ti.c.a(a)
s=p.d
if(s==null)s=p.d=A.fJ()
r=J.Y(a)&1073741823
q=s[r]
if(q==null)s[r]=[p.aI(a)]
else{if(p.ae(q,a)>=0)return!1
q.push(p.aI(a))}return!0},
aZ(a,b){this.$ti.c.a(b)
if(t.br.a(a[b])!=null)return!1
a[b]=this.aI(b)
return!0},
aI(a){var s=this,r=new A.cS(s.$ti.c.a(a))
if(s.e==null)s.e=s.f=r
else s.f=s.f.b=r;++s.a
s.r=s.r+1&1073741823
return r},
ae(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.U(a[r].a,b))return r
return-1}}
A.cS.prototype={}
A.aL.prototype={
gG(){var s=this.d
return s==null?this.$ti.c.a(s):s},
C(){var s=this,r=s.c,q=s.a
if(s.b!==q.r)throw A.c(A.ac(q))
else if(r==null){s.sa8(null)
return!1}else{s.sa8(s.$ti.i("1?").a(r.a))
s.c=r.b
return!0}},
sa8(a){this.d=this.$ti.i("1?").a(a)},
$iO:1}
A.u.prototype={
gU(a){return new A.R(a,this.gq(a),A.aO(a).i("R<u.E>"))},
a2(a,b){return this.j(a,b)},
gah(a){return this.gq(a)===0},
h(a,b){var s
A.aO(a).i("u.E").a(b)
s=this.gq(a)
this.sq(a,s+1)
this.l(a,s,b)},
a4(a,b){var s
for(s=0;s<this.gq(a);++s)this.j(a,s)
return!1},
n(a){return A.dl(a,"[","]")}}
A.aV.prototype={
au(a,b){var s,r,q,p=A.J(this)
p.i("~(1,2)").a(b)
for(s=this.gaO(),s=s.gU(s),p=p.y[1];s.C();){r=s.gG()
q=this.j(0,r)
b.$2(r,q==null?p.a(q):q)}},
gq(a){var s=this.gaO()
return s.gq(s)},
n(a){return A.fE(this)},
$iae:1}
A.ds.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.p(a)
s=r.a+=s
r.a=s+": "
s=A.p(b)
r.a+=s},
$S:23}
A.bs.prototype={
gU(a){var s=this
return new A.bP(s,s.c,s.d,s.b,s.$ti.i("bP<1>"))},
gah(a){return this.b===this.c},
gq(a){return(this.c-this.b&this.a.length-1)>>>0},
a2(a,b){var s,r,q=this,p=q.gq(0)
if(0>b||b>=p)A.as(A.dk(b,p,q,null,"index"))
p=q.a
s=p.length
r=(q.b+b&s-1)>>>0
if(!(r>=0&&r<s))return A.e(p,r)
r=p[r]
return r==null?q.$ti.c.a(r):r},
n(a){return A.dl(this,"{","}")},
P(){var s,r,q=this,p=q.b
if(p===q.c)throw A.c(A.hb());++q.d
s=q.a
if(!(p<s.length))return A.e(s,p)
r=s[p]
if(r==null)r=q.$ti.c.a(r)
B.a.l(s,p,null)
q.b=(q.b+1&q.a.length-1)>>>0
return r},
a7(a){var s,r,q,p,o=this,n=o.$ti
n.c.a(a)
B.a.l(o.a,o.c,a)
s=o.c
r=o.a.length
s=(s+1&r-1)>>>0
o.c=s
if(o.b===s){q=A.bt(r*2,null,!1,n.i("1?"))
n=o.a
s=o.b
p=n.length-s
B.a.az(q,0,p,n,s)
B.a.az(q,p,p+o.b,o.a,0)
o.b=0
o.c=o.a.length
o.sc5(q)}++o.d},
sc5(a){this.a=this.$ti.i("k<1?>").a(a)}}
A.bP.prototype={
gG(){var s=this.e
return s==null?this.$ti.c.a(s):s},
C(){var s,r,q=this,p=q.a
if(q.c!==p.d)A.as(A.ac(p))
s=q.d
if(s===q.b){q.sa8(null)
return!1}r=p.a
if(!(s<r.length))return A.e(r,s)
q.sa8(r[s])
q.d=(q.d+1&p.a.length-1)>>>0
return!0},
sa8(a){this.e=this.$ti.i("1?").a(a)},
$iO:1}
A.aZ.prototype={
n(a){return A.dl(this,"{","}")},
$ih:1}
A.bV.prototype={}
A.cg.prototype={
H(a,b){if(b==null)return!1
return b instanceof A.cg&&this.a===b.a},
gB(a){return B.b.gB(this.a)},
n(a){var s,r,q,p,o,n=this.a,m=B.b.V(n,36e8),l=n%36e8
if(n<0){m=0-m
n=0-l
s="-"}else{n=l
s=""}r=B.b.V(n,6e7)
n%=6e7
q=r<10?"0":""
p=B.b.V(n,1e6)
o=p<10?"0":""
return s+m+":"+q+r+":"+o+p+"."+B.i.cg(B.b.n(n%1e6),6,"0")}}
A.o.prototype={
gal(){return A.iW(this)}}
A.be.prototype={
n(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.ch(s)
return"Assertion failed"}}
A.aj.prototype={}
A.a6.prototype={
gaE(){return"Invalid argument"+(!this.a?"(s)":"")},
gaD(){return""},
n(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+A.p(p),n=s.gaE()+q+o
if(!s.a)return n
return n+s.gaD()+": "+A.ch(s.gaN())},
gaN(){return this.b}}
A.aX.prototype={
gaN(){return A.ju(this.b)},
gaE(){return"RangeError"},
gaD(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.p(q):""
else if(q==null)s=": Not greater than or equal to "+A.p(r)
else if(q>r)s=": Not in inclusive range "+A.p(r)+".."+A.p(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.p(r)
return s}}
A.cj.prototype={
gaN(){return A.P(this.b)},
gaE(){return"RangeError"},
gaD(){if(A.P(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gq(a){return this.f}}
A.bG.prototype={
n(a){return"Unsupported operation: "+this.a}}
A.cI.prototype={
n(a){return"UnimplementedError: "+this.a}}
A.b0.prototype={
n(a){return"Bad state: "+this.a}}
A.cd.prototype={
n(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.ch(s)+"."}}
A.cz.prototype={
n(a){return"Out of Memory"},
gal(){return null},
$io:1}
A.bD.prototype={
n(a){return"Stack Overflow"},
gal(){return null},
$io:1}
A.eX.prototype={
n(a){return"Exception: "+this.a}}
A.df.prototype={
n(a){var s=this.a,r=""!==s?"FormatException: "+s:"FormatException",q=this.b
if(q.length>78)q=B.i.bv(q,0,75)+"..."
return r+"\n"+q}}
A.h.prototype={
gq(a){var s,r=this.gU(this)
for(s=0;r.C();)++s
return s},
a2(a,b){var s,r
A.dD(b,"index")
s=this.gU(this)
for(r=b;s.C();){if(r===0)return s.gG();--r}throw A.c(A.dk(b,b-r,this,null,"index"))},
n(a){return A.hc(this,"(",")")}}
A.L.prototype={
gB(a){return A.n.prototype.gB.call(this,0)},
n(a){return"null"}}
A.n.prototype={$in:1,
H(a,b){return this===b},
gB(a){return A.cC(this)},
n(a){return"Instance of '"+A.dA(this)+"'"},
gL(a){return A.N(this)},
toString(){return this.n(this)}}
A.cU.prototype={
n(a){return""},
$ib_:1}
A.eK.prototype={
gcb(){var s,r=this.b
if(r==null)r=$.dC.$0()
s=r-this.a
if($.h0()===1e6)return s
return s*1000}}
A.cG.prototype={
gq(a){return this.a.length},
n(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.cR.prototype={
a3(a){if(a<=0||a>4294967296)throw A.c(A.hq("max must be in range 0 < max \u2264 2^32, was "+a))
return Math.random()*a>>>0},
K(){return Math.random()},
$iiY:1}
A.I.prototype={
n(a){return"Point("+this.a+", "+this.b+")"},
H(a,b){if(b==null)return!1
return b instanceof A.I&&this.a===b.a&&this.b===b.b},
gB(a){return A.hw(B.b.gB(this.a),B.b.gB(this.b),0)}}
A.bk.prototype={
aC(a){var s=this.b
if(!(a>=0&&a<s.length))return A.e(s,a)
s=s[a]
if(s==null){this.$ti.c.a(null)
s=null}return s},
h(a,b){var s,r,q,p,o=this,n=o.$ti
n.c.a(b);++o.d
s=o.c
r=o.b.length
if(s===r){q=r*2+1
if(q<7)q=7
p=A.bt(q,null,!1,n.i("1?"))
B.a.aW(p,0,o.c,o.b)
o.sbf(p)}o.b4(b,o.c++)},
gq(a){return this.c},
P(){var s,r,q,p=this
if(p.c===0)throw A.c(A.b1("No element"));++p.d
s=p.aC(0)
r=p.c-1
q=p.aC(r)
B.a.l(p.b,r,null)
p.c=r
if(r>0)p.bG(q,0)
return s},
n(a){var s=this.b
return A.hc(A.eN(s,0,A.fT(this.c,"count",t.S),A.F(s).c),"(",")")},
a0(a){var s,r,q,p,o=this,n=o.$ti
n.c.a(a)
s=o.c
r=o.b.length
if(s===r){q=r*2+1
if(q<7)q=7
p=A.bt(q,null,!1,n.i("1?"))
B.a.aW(p,0,o.c,o.b)
o.sbf(p)}o.b4(a,o.c++)},
b4(a,b){var s,r,q,p,o=this,n=o.$ti.c
n.a(a)
for(s=o.a;b>0;b=r){r=B.b.V(b-1,2)
q=o.b
if(!(r>=0&&r<q.length))return A.e(q,r)
p=q[r]
if(p==null){n.a(null)
p=null}q=s.$2(a,p)
if(typeof q!=="number")return q.cq()
if(q>0)break
B.a.l(o.b,b,p)}B.a.l(o.b,b,a)},
bG(a,b){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.$ti.c
h.a(a)
s=b*2+2
for(r=i.a;q=i.c,s<q;b=k){p=s-1
q=i.b
o=q.length
if(!(p>=0&&p<o))return A.e(q,p)
n=q[p]
if(n==null){h.a(null)
n=null}if(!(s>=0&&s<o))return A.e(q,s)
m=q[s]
if(m==null){h.a(null)
m=null}if(r.$2(n,m)<0){l=n
k=p}else{l=m
k=s}if(r.$2(a,l)<=0){B.a.l(i.b,b,a)
return}B.a.l(i.b,b,l)
s=k*2+2}p=s-1
if(p<q){j=i.aC(p)
if(r.$2(a,j)>0){B.a.l(i.b,b,j)
b=p}}B.a.l(i.b,b,a)},
sbf(a){this.b=this.$ti.i("k<1?>").a(a)}}
A.Z.prototype={
J(a){var s,r,q,p,o=new A.a(new Float64Array(2)),n=this.b,m=this.a.aQ(a.c,n)
for(s=m.length,n*=n,r=0,q=0;q<m.length;m.length===s||(0,A.l)(m),++q){p=m[q]
if(p===a)continue
if(a.c.af(p.c)<n)if(p.d.gt()>0.000001){o.h(0,p.d);++r}}if(r>0){o.A(1/r)
if(o.gt()>0.000001)return o.T().E(0,a.e).u(0,a.d)}return new A.a(new Float64Array(2))}}
A.aQ.prototype={
J(a){var s,r,q,p=this.a.u(0,a.c),o=p.gt()
if(o<this.d)return a.d.aw(0)
s=Math.sqrt(o)
r=this.b
q=a.e
if(s<r)q*=s/r
return p.aU(0,s).E(0,q).u(0,a.d)}}
A.a_.prototype={
J(a){var s,r,q,p,o,n=new A.a(new Float64Array(2)),m=this.b,l=this.a.aQ(a.c,m)
for(s=l.length,m*=m,r=0,q=0;q<l.length;l.length===s||(0,A.l)(l),++q){p=l[q]
if(p===a)continue
if(a.c.af(p.c)<m){n.h(0,p.c);++r}}if(r>0){n.A(1/r)
o=n.u(0,a.c)
if(o.gt()<0.0001)return new A.a(new Float64Array(2))
o.N()
o.A(a.e)
return o.u(0,a.d)}return new A.a(new Float64Array(2))}}
A.ce.prototype={
J(a){var s,r,q,p=this.b,o=this.a,n=a.c.O(0,a.d.T().E(0,p)).a,m=n[0],l=o.a,k=l.a,j=k[0],i=!1
if(m>=j){s=o.b.a
if(m<=s[0]){i=n[1]
i=i>=k[1]&&i<=s[1]}}if(i)return new A.a(new Float64Array(2))
r=new A.a(new Float64Array(2))
if(m<j){r.saS(1)
q=Math.max(0,(k[0]-n[0])/p)}else{j=o.b.a
if(m>j[0]){r.saS(-1)
q=Math.max(0,(n[0]-j[0])/p)}else q=0}m=n[1]
if(m<k[1]){r.saT(1)
q=Math.max(q,(k[1]-n[1])/p)}else{k=o.b.a
if(m>k[1]){r.saT(-1)
q=Math.max(q,(n[1]-k[1])/p)}}if(r.gt()>0.000001){r.N()
r.A(100*B.c.a9(q,0.1,1.5))}else{r.F(l.O(0,o.b).E(0,0.5).u(0,a.c))
if(r.gt()>0.000001){r.N()
r.A(10)}else return new A.a(new Float64Array(2))}return r}}
A.bh.prototype={
J(a){var s,r,q=this.a,p=q.c.u(0,a.c),o=Math.sqrt(p.gt())
if(q.d.gt()<0.010000000000000002)return this.b8(a,q.c)
s=a.e
r=s>0.000001?o/s:0
p.F(q.d)
p.A(r)
p.h(0,q.c)
return this.b8(a,p)},
b8(a,b){var s,r,q=a.c.u(0,b)
if(q.gt()<1e-9){q.F(a.c.u(0,this.a.c))
s=q.gt()
r=a.e
if(s<1e-9)q.m(r,0)
else q.sq(0,r)}else{q.N()
q.A(a.e)}return q.u(0,a.d)}}
A.bi.prototype={
J(a){var s=a.c.u(0,this.a),r=s.gt()
if(r<0.0001)return new A.a(new Float64Array(2))
return s.T().E(0,a.e).u(0,a.d)}}
A.ci.prototype={
J(a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3=this.b>0.000001&&a5.d.gt()>0.000001,a4=a5.c
if(a3)a4=a4.O(0,a5.d.T().E(0,this.b))
a3=this.a
s=a4.a
r=s[0]
q=a3.a.a
p=q[0]
o=a3.b
s=s[1]
q=q[1]
n=a3.c
m=n-1
l=B.c.a9((r-p)/o,0,m)
p=a3.d-1
k=B.c.a9((s-q)/o,0,p)
j=B.c.Z(l)
i=B.c.Z(k)
h=l-j
g=k-i
f=j>=m?j:j+1
e=i>=p?i:i+1
a3=a3.e
s=i*n
r=s+j
q=a3.length
if(!(r>=0&&r<q))return A.e(a3,r)
d=a3[r]
s+=f
if(!(s>=0&&s<q))return A.e(a3,s)
c=a3[s]
n=e*n
s=n+j
if(!(s>=0&&s<q))return A.e(a3,s)
b=a3[s]
n+=f
if(!(n>=0&&n<q))return A.e(a3,n)
a=a3[n]
n=d.a
a3=n[0]
q=1-h
s=c.a
r=s[0]
n=n[1]
s=s[1]
p=b.a
o=p[0]
m=a.a
a0=m[0]
p=p[1]
m=m[1]
a1=1-g
a2=new A.a(new Float64Array(2))
a2.m((a3*q+r*h)*a1+(o*q+a0*h)*g,(n*q+s*h)*a1+(p*q+m*h)*g)
if(a2.gt()===0)return new A.a(new Float64Array(2))
return a2.T().E(0,a5.e).u(0,a5.d)}}
A.ad.prototype={
J(a){var s,r,q,p,o,n,m,l,k=this,j=k.a,i=j.d,h=i.gt()>0.000001?i.T():null,g=h!=null,f=k.c
if(g){s=h.aw(0).E(0,f)
r=j.c.O(0,s)}else{q=j.c
p=new A.a(new Float64Array(2))
p.m(f,0)
r=q.u(0,p)}new Float64Array(2)
if(g){o=a.c.u(0,j.c)
n=o.ar(h)
m=o.u(0,h.E(0,n)).gt()
j=!1
if(n>0)if(n<k.d){j=k.e
j=m<j*j}if(j){A.kw("LeaderFollowing: EVADING!")
j=k.w
j===$&&A.f()
return j.J(a)}}j=k.f
j===$&&A.f()
j.a=r
l=j.J(a)
j=k.r
j===$&&A.f()
if(j!=null)l.h(0,j.J(a))
return l}}
A.af.prototype={
J(a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=this
if(a3.d.gt()<0.000001){s=a2.x
s.ai()
return s}r=a2.b
s=a2.d
s.F(a3.d)
s.N()
for(q=a2.a,p=q.length,o=a2.f,n=s.a,m=o.a,l=m.$flags|0,k=a2.e,j=k.a,i=j.$flags|0,h=null,g=1/0,f=0;f<q.length;q.length===p||(0,A.l)(q),++f){e=q[f]
d=e.a
c=a3.w
c=c>0?c:0.1
b=c+e.b
a=d.a
c=a[1]
i&2&&A.A(j)
j[1]=c
j[0]=a[0]
k.a6(a3.c)
a0=k.ar(s)
if(a0<0||a0>r)continue
c=n[1]
l&2&&A.A(m)
m[1]=c
m[0]=n[0]
o.A(a0)
o.h(0,a3.c)
if(d.af(o)<b*b)if(a0<g){g=a0
h=e}}if(h!=null){q=a2.r
q.F(h.a)
q.a6(a3.c)
a1=q.ar(s)
p=a2.w
p.F(s)
p.A(a1)
p.F(q)
p.a6(s.E(0,a1))
if(p.gt()>0.000001){s=a2.x
s.F(p)
s.N()
s.aP()
s.A(a2.c*((r-g)/r))
a2.y.F(s)
return s}}a2.y.ai()
s=a2.x
s.ai()
return s}}
A.bC.prototype={
J(a){var s,r,q,p,o,n,m=this,l=m.a,k=Math.sqrt(l.c.u(0,a.c).gt()),j=Math.sqrt(l.d.gt()),i=j>0.000001?k/j:0
if(i>1)i=1
s=l.c.O(0,l.d.E(0,i))
r=l.d
if(r.gt()<0.000001)q=l.c.O(0,m.b)
else{p=r.T()
l=p.a
o=l[1]
l=l[0]
n=new A.a(new Float64Array(2))
n.m(-o,l)
l=m.b.a
q=s.O(0,p.E(0,l[0]).O(0,n.E(0,l[1])))}return m.bE(a,q)},
bE(a,b){var s,r=b.u(0,a.c),q=Math.sqrt(r.gt())
if(q<0.5)return a.d.aw(0)
s=a.e
if(q<5)s*=q/Math.max(5,0.000001)
if(q<0.000001)return new A.a(new Float64Array(2))
return r.aU(0,q).E(0,s).u(0,a.d)}}
A.a0.prototype={
J(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this
if(a.d.gt()<0.000001)return new A.a(new Float64Array(2))
s=c.b
r=a.c.O(0,a.d.T().E(0,s))
q=new A.a(new Float64Array(2))
p=c.c
for(o=c.a,n=o.a,m=n.length,l=m-1,k=1/0,j=0;j<3;++j){i=c.c+j
h=B.b.ac(i,l)
i=i>=l
if(i)h=l-1
g=c.bO(n[B.b.ac(h,m)],n[B.b.ac(h+1,m)],r)
f=r.af(g)
if(f<k){p=h
k=f
q=g}i=h===l-1
if(i)break}n=c.c
if(p!==n)if(p-n>0)c.c=p
else if(p===o.gbt()-1&&c.c!==p)c.c=p
n=new A.a(new Float64Array(2))
n.F(q)
c.d=n
if(Math.sqrt(k)>o.b)e=q
else{d=o.bs(c.c)
e=q.O(0,o.br(c.c).u(0,d).T().E(0,s))}return c.bV(a,e)},
bO(a,b,c){var s=c.u(0,a),r=b.u(0,a),q=r.gt()
if(q===0)return a
return a.O(0,r.E(0,B.c.a9(s.ar(r)/q,0,1)))},
bV(a,b){var s=b.u(0,a.c)
if(s.gt()<0.000001)return new A.a(new Float64Array(2))
s.N()
s.A(a.e)
return s.u(0,a.d)}}
A.cD.prototype={
J(a){var s,r,q=this.a,p=Math.sqrt(q.c.u(0,a.c).gt())
if(q.d.gt()<0.010000000000000002||p<0.1)return this.be(a,q.c)
s=a.e
r=s>0.000001?p/s:0
return this.be(a,q.c.O(0,q.d.E(0,r)))},
be(a,b){var s=b.u(0,a.c)
if(s.gt()<0.0001)return new A.a(new Float64Array(2))
s.N()
s.A(a.e)
return s.u(0,a.d)}}
A.aK.prototype={
J(a){var s=this.a.u(0,a.c)
if(s.gt()<0.0001)return new A.a(new Float64Array(2))
s.N()
s.A(a.e)
return s.u(0,a.d)}}
A.a1.prototype={
J(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=new A.a(new Float64Array(2)),e=this.b,d=this.a.aQ(a.c,e)
for(s=d.length,r=e*e,q=0,p=0;p<d.length;d.length===s||(0,A.l)(d),++p){o=d[p]
if(o===a)continue
n=o.c
m=a.c
l=new Float64Array(2)
k=new A.a(l)
j=n.a
l[1]=j[1]
l[0]=j[0]
k.a6(m)
i=k.gt()
if(i>0.000001&&i<r){h=Math.sqrt(i)
n=new Float64Array(2)
n[1]=l[1]
n[0]=l[0]
new A.a(n).aP()
m=new Float64Array(2)
m[1]=n[1]
m[0]=n[0]
new A.a(m).A(1/h)
n=new Float64Array(2)
g=new A.a(n)
n[1]=m[1]
n[0]=m[0]
g.A(e/h)
f.h(0,g);++q}}if(q>0)if(f.gt()>0.000001)return f.T().E(0,a.e).u(0,a.d)
return new A.a(new Float64Array(2))}}
A.al.prototype={
J(b0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9=this
if(b0.d.gt()<0.000001)return new A.a(new Float64Array(2))
s=b0.d.T().a
r=s[1]
q=s[0]
p=new Float64Array(2)
new A.a(p).m(-r,q)
for(r=a9.e,q=r.length,o=a9.a,n=1/0,m=null,l=null,k=0;k<r.length;r.length===q||(0,A.l)(r),++k){j=r[k]
i=b0.c
h=i.a
g=h[0]
f=j.a
e=f[0]
d=s[0]
f=f[1]
c=p[0]
h=h[1]
b=s[1]
a=p[1]
a0=new Float64Array(2)
a1=new A.a(a0)
a0[0]=g+e*d+f*c
a0[1]=h+e*b+f*a
for(h=o.length,a2=0;a2<o.length;o.length===h||(0,A.l)(o),++a2){a3=o[a2]
a4=a9.bR(i,a1,a3.a,a3.b)
if(a4!=null){a5=b0.c.af(a4)
if(a5<n){l=a4
m=a3
n=a5}}}}a6=new A.a(new Float64Array(2))
if(m!=null&&l!=null){s=m.b.u(0,m.a).a
r=s[1]
s=s[0]
q=new A.a(new Float64Array(2))
q.m(-r,s)
a7=q.T()
q=a9.c
a8=q-Math.sqrt(n)
if(a8>0)a6=a7.E(0,a8*a9.d/q)}return a6},
bR(a,b,c,d){var s,r,q,p,o=a.a,n=o[0],m=b.a,l=m[0],k=n-l,j=c.a,i=j[1],h=d.a,g=i-h[1]
o=o[1]
m=m[1]
s=o-m
j=j[0]
h=j-h[0]
r=k*g-s*h
if(Math.abs(r)<0.000001)return null
j=n-j
i=o-i
q=(j*g-i*h)/r
p=-(k*i-s*j)/r
if(q>=0&&q<=1&&p>=0&&p<=1){k=new A.a(new Float64Array(2))
k.m(n+q*(l-n),o+q*(m-o))
return k}return null}}
A.am.prototype={
J(a){var s,r,q,p,o,n,m=this,l=m.c*(m.d.K()-0.5)
m.e+=l
s=m.f
s.F(a.d)
if(s.gt()<0.000001)s.m(1,0)
s.N()
s.A(m.a)
s.h(0,a.c)
r=m.r
r.m(Math.cos(m.e),Math.sin(m.e))
r.A(m.b)
q=a.d.T()
p=q.a
o=p[1]
p=p[0]
n=new A.a(new Float64Array(2))
n.m(-o,p)
p=m.w
p.F(q)
r=r.a
p.A(r[0])
n.A(r[1])
p.h(0,n)
p.h(0,s)
s=m.x
s.F(p)
s.a6(a.c)
s.N()
s.A(a.e)
p=m.y
p.F(s)
p.a6(a.d)
return p}}
A.de.prototype={
aV(a,b,c){var s,r=this,q=!1
if(a<r.c)q=b<r.d
if(q){s=b*r.c+a
q=r.e
if(!(s>=0&&s<q.length))return A.e(q,s)
q[s].F(c)}},
bp(a,b){var s,r=this,q=!1
if(a<r.c)q=b<r.d
if(q){s=b*r.c+a
q=r.e
if(!(s>=0&&s<q.length))return A.e(q,s)
return q[s]}return null}}
A.aH.prototype={$icy:1}
A.az.prototype={$icy:1}
A.ah.prototype={$icy:1}
A.dw.prototype={
gbt(){return this.a.length-1},
bs(a){var s=this.a
return s[B.b.ac(a,s.length)]},
br(a){var s=this.a
return s[B.b.ac(a+1,s.length)]}}
A.dy.prototype={
$1(a){var s
t.h.a(a)
s=new A.a(new Float64Array(2))
s.F(a)
return s},
$S:24}
A.c9.prototype={
W(a,a0,a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this,e=++a3.d,d=A.a8(new A.d_(),t.A),c=null,b=null
try{c=a3.p(a,a0)
b=a3.p(a1,a2)}catch(s){e=A.d([],t._)
return e}c.R(e)
b.I(e)
if(!c.c||!b.c)return A.d([],t._)
c.f=0
r=c
q=f.d
p=f.c
o=p.$2(Math.abs(c.a-b.a),Math.abs(c.b-b.b))
if(typeof o!=="number")return A.a4(o)
r.r=q*o
c.x=!0
d.h(0,c)
for(r=d.$ti.c,o=f.a,n=f.b;d.c!==0;){m=d.P()
m.w=!0
if(m.H(0,b))return A.ag(b)
l=a3.M(m,o,n)
for(k=l.length,j=0;j<l.length;l.length===k||(0,A.l)(l),++j){i=l[j]
i.I(e)
if(!i.c||i.w)continue
h=m.f+f.ab(m,i)
if(h<i.f||!i.x){i.f=h
g=p.$2(Math.abs(i.a-b.a),Math.abs(i.b-b.b))
if(typeof g!=="number")return A.a4(g)
i.r=q*g
i.e=m
if(!i.x){r.a(i);++d.d
d.a0(i)
i.x=!0}}}}return A.d([],t._)}}
A.d_.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.f+a.r,b.f+b.r)},
$S:2}
A.d0.prototype={
W(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i=++e.d,h=A.a8(new A.d1(),t.A),g=null,f=null
try{g=e.p(a,b)
f=e.p(c,d)}catch(s){i=A.d([],t._)
return i}g.R(i)
f.I(i)
if(!g.c||!f.c)return A.d([],t._)
g.f=0
r=this.c
g.sag(r.$2(Math.abs(a-f.a),Math.abs(b-f.b)))
g.x=!0
h.h(0,g)
for(q=h.$ti.c,p=this.a,o=this.b;h.c!==0;){n=h.P()
n.w=!0
if(n.H(0,f))return A.ag(f)
m=e.M(n,p,o)
for(l=m.length,k=0;k<m.length;m.length===l||(0,A.l)(m),++k){j=m[k]
j.I(i)
if(!j.c||j.w||j.x)continue
j.e=n
j.sag(r.$2(Math.abs(j.a-f.a),Math.abs(j.b-f.b)))
j.x=!0
q.a(j);++h.d
h.a0(j)}}return A.d([],t._)}}
A.d1.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.r,b.r)},
$S:2}
A.dc.prototype={
W(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j=++e.d,i=A.fD(t.A),h=null,g=null
try{h=e.p(a,b)
g=e.p(c,d)}catch(s){j=A.d([],t._)
return j}h.R(j)
g.I(j)
if(!h.c||!g.c)return A.d([],t._)
h.x=!0
r=i.$ti.c
i.a7(r.a(h))
for(q=this.a,p=this.b;!i.gah(0);){o=i.P()
o.w=!0
if(o.H(0,g))return A.ag(g)
n=e.M(o,q,p)
for(m=n.length,l=0;l<n.length;n.length===m||(0,A.l)(n),++l){k=n[l]
k.I(j)
if(!k.c||k.x||k.w)continue
k.e=o
k.x=!0
i.a7(r.a(k))}}return A.d([],t._)}}
A.d2.prototype={
W(b7,b8,b9,c0,c1){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2=this,b3="No element",b4=++c1.d,b5=null,b6=null
try{b5=c1.p(b7,b8)
b6=c1.p(b9,c0)}catch(s){b4=A.d([],t._)
return b4}r=t.A
q=A.a8(new A.d3(),r)
p=A.a8(new A.d4(),r)
o=t.i
n=A.H(r,o)
m=A.H(r,o)
l=A.H(r,r)
k=A.H(r,r)
j=A.H(r,t.S)
b5.R(b4)
b6.R(b4)
if(!b5.c||!b6.c)return A.d([],t._)
n.l(0,b5,0)
r=b5
o=b2.d
i=b2.c
h=i.$2(Math.abs(b7-b9),Math.abs(b8-c0))
if(typeof h!=="number")return A.a4(h)
r.r=o*h
q.h(0,b5)
j.l(0,b5,1)
b5.x=!0
m.l(0,b6,0)
h=b6
r=i.$2(Math.abs(b9-b7),Math.abs(c0-b8))
if(typeof r!=="number")return A.a4(r)
h.r=o*r
p.h(0,b6)
j.l(0,b6,2)
b6.x=!0
r=q.$ti.c
h=p.$ti.c
g=b2.a
f=b2.b
e=1/0
d=null
while(!0){c=q.c===0
if(!(!c&&p.c!==0))break
if(c)A.as(A.b1(b3))
c=q.b
if(0>=c.length)return A.e(c,0)
c=c[0]
if(c==null){r.a(null)
c=null}c=n.j(0,c)
c.toString
if(q.c===0)A.as(A.b1(b3))
b=q.b
if(0>=b.length)return A.e(b,0)
b=b[0]
if(b==null){r.a(null)
b=null}b=b.r
if(p.c===0)A.as(A.b1(b3))
a=p.b
if(0>=a.length)return A.e(a,0)
a=a[0]
if(a==null){h.a(null)
a=null}a=m.j(0,a)
a.toString
if(p.c===0)A.as(A.b1(b3))
a0=p.b
if(0>=a0.length)return A.e(a0,0)
a0=a0[0]
if(a0==null){h.a(null)
a0=null}a0=a0.r
if(d!=null&&c+b+(a+a0)>=e)return b2.b2(d,l,k)
if(q.c!==0){a1=q.P()
a1.w=!0
if(j.j(0,a1)===2){c=n.j(0,a1)
c.toString
b=m.j(0,a1)
b.toString
a2=c+b
if(a2<e){d=a1
e=a2}}a3=c1.M(a1,g,f)
for(c=a3.length,a4=0;a4<a3.length;a3.length===c||(0,A.l)(a3),++a4){a5=a3[a4]
a5.I(b4)
if(!a5.c||j.j(0,a5)===1)continue
b=n.j(0,a1)
b.toString
a6=b+b2.ab(a1,a5)*a5.d
if(j.j(0,a5)===2){b=m.j(0,a5)
b.toString
a2=a6+b
if(a2<e){l.l(0,a5,a1)
d=a5
e=a2}}a7=n.j(0,a5)
if(a6<(a7==null?1/0:a7)){n.l(0,a5,a6)
l.l(0,a5,a1)
a5.f=a6
b=i.$2(Math.abs(a5.a-b9),Math.abs(a5.b-c0))
if(typeof b!=="number")return A.a4(b)
a5.r=o*b
if(j.j(0,a5)!==1){r.a(a5);++q.d
q.a0(a5)
j.l(0,a5,1)
a5.x=!0}}}}if(p.c!==0){a8=p.P()
a8.w=!0
if(j.j(0,a8)===1){c=m.j(0,a8)
c.toString
b=n.j(0,a8)
b.toString
a2=c+b
if(a2<e){d=a8
e=a2}}a9=c1.M(a8,g,f)
for(c=a9.length,a4=0;a4<a9.length;a9.length===c||(0,A.l)(a9),++a4){a5=a9[a4]
a5.I(b4)
if(!a5.c||j.j(0,a5)===2)continue
b=m.j(0,a8)
b.toString
b0=b+b2.ab(a8,a5)*a5.d
if(j.j(0,a5)===1){b=n.j(0,a5)
b.toString
a2=b0+b
if(a2<e){k.l(0,a5,a8)
d=a5
e=a2}}b1=m.j(0,a5)
if(b0<(b1==null?1/0:b1)){m.l(0,a5,b0)
k.l(0,a5,a8)
a5.f=b0
b=i.$2(Math.abs(a5.a-b7),Math.abs(a5.b-b8))
if(typeof b!=="number")return A.a4(b)
a5.r=o*b
if(j.j(0,a5)!==2){h.a(a5);++p.d
p.a0(a5)
j.l(0,a5,2)
a5.x=!0}}}}}return d!=null?b2.b2(d,l,k):A.d([],t._)},
b2(a,b,c){var s,r,q,p=t.q
p.a(b)
p.a(c)
p=t._
s=A.d([],p)
for(r=a;r!=null;){B.a.h(s,r)
r=b.j(0,r)}q=A.d([],p)
r=c.j(0,a)
for(;r!=null;){B.a.h(q,r)
r=c.j(0,r)}p=t.V
p=A.a9(new A.S(s,p),!0,p.i("v.E"))
B.a.aq(p,q)
return p}}
A.d3.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.f+a.r,b.f+b.r)},
$S:2}
A.d4.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.f+a.r,b.f+b.r)},
$S:2}
A.d5.prototype={
W(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=this,a0=++a7.d,a1=null,a2=null
try{a1=a7.p(a3,a4)
a2=a7.p(a5,a6)}catch(s){a0=A.d([],t._)
return a0}r=t.A
q=A.a8(new A.d6(),r)
p=A.a8(new A.d7(),r)
o=A.H(r,r)
n=A.H(r,r)
m=A.H(r,t.S)
a1.R(a0)
a2.R(a0)
if(!a1.c||!a2.c)return A.d([],t._)
if(J.U(a1,a2))return A.d([a1],t._)
r=a.c
a1.sag(r.$2(Math.abs(a3-a5),Math.abs(a4-a6)))
q.h(0,a1)
m.l(0,a1,1)
o.l(0,a1,a1)
a1.x=!0
a2.sag(r.$2(Math.abs(a5-a3),Math.abs(a6-a4)))
p.h(0,a2)
m.l(0,a2,2)
n.l(0,a2,a2)
a2.x=!0
l=q.$ti.c
k=a.a
j=a.b
i=p.$ti.c
while(!0){h=q.c!==0
if(!(h&&p.c!==0))break
if(h){g=q.P()
g.w=!0
f=a7.M(g,k,j)
for(h=f.length,e=0;e<f.length;f.length===h||(0,A.l)(f),++e){d=f[e]
d.I(a0)
if(!d.c||m.j(0,d)===1)continue
if(m.j(0,d)===2){o.l(0,d,g)
return a.b1(d,o,n)}m.l(0,d,1)
o.l(0,d,g)
d.sag(r.$2(Math.abs(d.a-a5),Math.abs(d.b-a6)))
d.x=!0
l.a(d);++q.d
q.a0(d)}}if(p.c!==0){c=p.P()
c.w=!0
b=a7.M(c,k,j)
for(h=b.length,e=0;e<b.length;b.length===h||(0,A.l)(b),++e){d=b[e]
d.I(a0)
if(!d.c||m.j(0,d)===2)continue
if(m.j(0,d)===1){n.l(0,d,c)
return a.b1(d,o,n)}m.l(0,d,2)
n.l(0,d,c)
d.sag(r.$2(Math.abs(d.a-a3),Math.abs(d.b-a4)))
d.x=!0
i.a(d);++p.d
p.a0(d)}}}return A.d([],t._)},
b1(a,b,c){var s,r,q,p,o=t.q
o.a(b)
o.a(c)
o=t._
s=A.d([],o)
r=a
while(!0){q=r!=null
if(!(q&&!J.U(b.j(0,r),r)))break
B.a.h(s,r)
r=b.j(0,r)}if(q)B.a.h(s,r)
p=A.d([],o)
r=c.j(0,a)
while(!0){o=r!=null
if(!(o&&!J.U(c.j(0,r),r)))break
B.a.h(p,r)
r=c.j(0,r)}if(o)B.a.h(p,r)
o=t.V
o=A.a9(new A.S(s,o),!0,o.i("v.E"))
B.a.aq(o,p)
return o}}
A.d6.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.r,b.r)},
$S:2}
A.d7.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.r,b.r)},
$S:2}
A.d8.prototype={
W(a1,a2,a3,a4,a5){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b=++a5.d,a=null,a0=null
try{a=a5.p(a1,a2)
a0=a5.p(a3,a4)}catch(s){b=A.d([],t._)
return b}r=t.A
q=A.fD(r)
p=A.fD(r)
a.R(b)
a0.R(b)
if(!a.c||!a0.c)return A.d([],t._)
if(J.U(a,a0))return A.d([a],t._)
a.x=!0
a.w=!0
r=q.$ti.c
q.a7(r.a(a))
a0.x=!0
a0.w=!1
o=p.$ti.c
p.a7(o.a(a0))
n=this.a
m=this.b
while(!0){if(!(!q.gah(0)&&!p.gah(0)))break
l=(q.c-q.b&q.a.length-1)>>>0
for(k=0;k<l;++k){j=q.P()
i=a5.M(j,n,m)
for(h=i.length,g=0;g<i.length;i.length===h||(0,A.l)(i),++g){f=i[g]
f.I(b)
if(!f.c)continue
if(f.x){if(!f.w){e=A.ag(j)
d=A.ag(f)
b=A.F(d).i("S<1>")
return B.a.O(e,A.a9(new A.S(d,b),!0,b.i("v.E")))}continue}f.e=j
f.w=f.x=!0
q.a7(r.a(f))}}c=(p.c-p.b&p.a.length-1)>>>0
for(k=0;k<c;++k){j=p.P()
i=a5.M(j,n,m)
for(h=i.length,g=0;g<i.length;i.length===h||(0,A.l)(i),++g){f=i[g]
f.I(b)
if(!f.c)continue
if(f.x){if(f.w){e=A.ag(f)
d=A.ag(j)
b=A.F(d).i("S<1>")
return B.a.O(e,A.a9(new A.S(d,b),!0,b.i("v.E")))}continue}f.e=j
f.x=!0
f.w=!1
p.a7(o.a(f))}}}return A.d([],t._)}}
A.d9.prototype={
W(b3,b4,b5,b6,b7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8=this,a9="No element",b0=++b7.d,b1=null,b2=null
try{b1=b7.p(b3,b4)
b2=b7.p(b5,b6)}catch(s){b0=A.d([],t._)
return b0}r=t.A
q=t.i
p=A.H(r,q)
o=A.H(r,q)
n=A.H(r,r)
m=A.H(r,r)
l=A.H(r,t.S)
k=A.a8(new A.da(p),r)
j=A.a8(new A.db(o),r)
b1.R(b0)
b2.R(b0)
if(!b1.c||!b2.c)return A.d([],t._)
if(J.U(b1,b2))return A.d([b1],t._)
p.l(0,b1,0)
k.h(0,b1)
l.l(0,b1,1)
b1.x=!0
o.l(0,b2,0)
j.h(0,b2)
l.l(0,b2,2)
b2.x=!0
r=k.$ti.c
q=j.$ti.c
i=a8.a
h=a8.b
g=1/0
f=null
while(!0){e=k.c===0
if(!(!e&&j.c!==0))break
if(e)A.as(A.b1(a9))
e=k.b
if(0>=e.length)return A.e(e,0)
e=e[0]
if(e==null){r.a(null)
e=null}e=p.j(0,e)
e.toString
if(j.c===0)A.as(A.b1(a9))
d=j.b
if(0>=d.length)return A.e(d,0)
d=d[0]
if(d==null){q.a(null)
d=null}d=o.j(0,d)
d.toString
if(f!=null&&e+d>=g)return a8.b3(f,n,m)
if(k.c!==0){c=k.P()
b=b7.M(c,i,h)
for(e=b.length,a=0;a<b.length;b.length===e||(0,A.l)(b),++a){a0=b[a]
a0.I(b0)
if(!a0.c||l.j(0,a0)===1)continue
d=p.j(0,c)
d.toString
a1=d+a8.ab(c,a0)
if(l.j(0,a0)===2){d=o.j(0,a0)
d.toString
a2=a1+d
if(a2<g){n.l(0,a0,c)
f=a0
g=a2}}a3=p.j(0,a0)
if(a1<(a3==null?1/0:a3)){p.l(0,a0,a1)
n.l(0,a0,c)
a0.x=!0
if(l.j(0,a0)!==1){r.a(a0);++k.d
k.a0(a0)
l.l(0,a0,1)}}}}if(j.c!==0){a4=j.P()
a5=b7.M(a4,i,h)
for(e=a5.length,a=0;a<a5.length;a5.length===e||(0,A.l)(a5),++a){a0=a5[a]
a0.I(b0)
if(!a0.c||l.j(0,a0)===2)continue
d=o.j(0,a4)
d.toString
a6=d+a8.ab(a4,a0)
if(l.j(0,a0)===1){d=p.j(0,a0)
d.toString
a2=a6+d
if(a2<g){m.l(0,a0,a4)
f=a0
g=a2}}a7=o.j(0,a0)
if(a6<(a7==null?1/0:a7)){o.l(0,a0,a6)
m.l(0,a0,a4)
a0.x=!0
if(l.j(0,a0)!==2){q.a(a0);++j.d
j.a0(a0)
l.l(0,a0,2)}}}}}return f!=null?a8.b3(f,n,m):A.d([],t._)},
b3(a,b,c){var s,r,q,p=t.q
p.a(b)
p.a(c)
p=t._
s=A.d([],p)
for(r=a;r!=null;){B.a.h(s,r)
r=b.j(0,r)}q=A.d([],p)
r=c.j(0,a)
for(;r!=null;){B.a.h(q,r)
r=c.j(0,r)}p=t.V
p=A.a9(new A.S(s,p),!0,p.i("v.E"))
B.a.aq(p,q)
return p}}
A.da.prototype={
$2(a,b){var s,r=t.A
r.a(a)
r.a(b)
r=this.a
s=r.j(0,a)
s.toString
r=r.j(0,b)
r.toString
return B.c.S(s,r)},
$S:2}
A.db.prototype={
$2(a,b){var s,r=t.A
r.a(a)
r.a(b)
r=this.a
s=r.j(0,a)
s.toString
r=r.j(0,b)
r.toString
return B.c.S(s,r)},
$S:2}
A.cf.prototype={
W(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i=++e.d,h=A.a8(new A.dd(),t.A),g=null,f=null
try{g=e.p(a,b)
f=e.p(c,d)}catch(s){i=A.d([],t._)
return i}g.R(i)
f.I(i)
if(!g.c||!f.c)return A.d([],t._)
g.f=0
g.x=!0
h.h(0,g)
for(r=h.$ti.c,q=this.a,p=this.b;h.c!==0;){o=h.P()
o.w=!0
if(o.H(0,f))return A.ag(f)
n=e.M(o,q,p)
for(m=n.length,l=0;l<n.length;n.length===m||(0,A.l)(n),++l){k=n[l]
k.I(i)
if(!k.c||k.w)continue
j=o.f+this.ab(o,k)
if(j<k.f||!k.x){k.f=j
k.e=o
if(!k.x){r.a(k);++h.d
h.a0(k)
k.x=!0}}}}return A.d([],t._)}}
A.dd.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.f,b.f)},
$S:2}
A.dj.prototype={
W(a,b,c,d,e){var s,r,q,p,o,n=null,m=null
try{n=e.p(a,b)
m=e.p(c,d)}catch(s){r=A.d([],t._)
return r}if(!n.c||!m.c)return A.d([],t._)
r=this.c.$2(Math.abs(a-m.a),Math.abs(b-m.b))
if(typeof r!=="number")return A.a4(r)
q=this.d*r
for(p=e.a*e.b*10,r=t.b;!0;q=o){o=this.bg(n,0,q,m,e,0)
if(r.b(o))return o
if(o===1/0)return A.d([],t._)
A.aM(o)
if(o>p)return A.d([],t._)}},
bg(a,b,c,d,e,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f=this
if(a0>1e6)return 1/0
s=f.c.$2(Math.abs(a.a-d.a),Math.abs(a.b-d.b))
if(typeof s!=="number")return A.a4(s)
r=b+f.d*s
if(r>c)return r
if(a.H(0,d)){q=A.d([],t._)
for(p=a;p!=null;){B.a.h(q,p)
p=p.e}s=t.V
return A.a9(new A.S(q,s),!0,s.i("v.E"))}o=e.M(a,f.a,f.b)
for(s=o.length,n=t.b,m=a0+1,l=1/0,k=0;k<o.length;o.length===s||(0,A.l)(o),++k){j=o[k]
if(j.H(0,a.e))continue
if(!j.c)continue
i=f.ab(a,j)
h=j.e
j.e=a
g=f.bg(j,b+i,c,d,e,m)
i=n.b(g)
if(!i)j.e=h
if(i)return g
if(typeof g!=="number")return g.cr()
if(g<l)l=g}return l}}
A.dn.prototype={
W(a,b,c,d,e){var s,r,q,p=++e.d,o=A.a8(new A.dp(),t.A),n=null,m=null
try{n=e.p(a,b)
m=e.p(c,d)}catch(s){p=A.d([],t._)
return p}n.R(p)
m.I(p)
if(!n.c||!m.c)return A.d([],t._)
n.f=0
p=n
r=this.c.$2(Math.abs(a-m.a),Math.abs(b-m.b))
if(typeof r!=="number")return A.a4(r)
p.r=this.d*r
n.x=!0
o.h(0,n)
for(;o.c!==0;){q=o.P()
q.w=!0
if(q.H(0,m))return A.ag(m)
this.bQ(q,e,m,o)}return A.d([],t._)},
bQ(a9,b0,b1,b2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8
t.t.a(b2)
s=b0.d
r=a9.a
q=a9.b
p=a9.e
o=A.d([],t.ce)
if(p!=null){n=p.a
m=p.b
l=B.b.gad(r-n)
k=B.b.gad(q-m)
j=l===0
if(!j&&k!==0){j=q+k
if(b0.k(r,j))B.a.h(o,new A.j(0,k))
i=r+l
if(b0.k(i,q))B.a.h(o,new A.j(l,0))
if(b0.k(r,j)||b0.k(i,q))if(b0.k(i,j))B.a.h(o,new A.j(l,k))
h=r-l
if(!b0.k(h,q)&&b0.k(r,j))if(b0.k(h,j))B.a.h(o,new A.j(-l,k))
j=q-k
if(!b0.k(r,j)&&b0.k(i,q))if(b0.k(i,j))B.a.h(o,new A.j(l,-k))}else if(j){j=q+k
if(b0.k(r,j)){B.a.h(o,new A.j(0,k))
i=r+1
if(!b0.k(i,q)&&b0.k(i,j))B.a.h(o,new A.j(1,k))
i=r-1
if(!b0.k(i,q)&&b0.k(i,j))B.a.h(o,new A.j(-1,k))}}else{j=r+l
if(b0.k(j,q)){B.a.h(o,new A.j(l,0))
i=q+1
if(!b0.k(r,i)&&b0.k(j,i))B.a.h(o,new A.j(l,1))
i=q-1
if(!b0.k(r,i)&&b0.k(j,i))B.a.h(o,new A.j(l,-1))}}}else{g=b0.M(a9,!0,!1)
for(j=g.length,f=0;f<g.length;g.length===j||(0,A.l)(g),++f){e=g[f]
B.a.h(o,new A.j(e.a-r,e.b-q))}}for(j=o.length,i=this.d,h=b1.a,d=b1.b,c=this.c,b=b2.$ti.c,f=0;f<o.length;o.length===j||(0,A.l)(o),++f){a=o[f]
a0=this.an(r,q,a.a,a.b,b0,b1)
if(a0!=null){a1=a0.a
a2=a0.b
a3=b0.p(a1,a2)
a3.I(s)
if(a3.w)continue
a4=Math.abs(Math.abs(r-a1))
a5=Math.abs(Math.abs(q-a2))
a6=Math.max(a4,a5)
a7=Math.min(a4,a5)
a8=a9.f+(a6+0.4142135623730949*a7)
if(a8<a3.f||!a3.x){a3.f=a8
a6=c.$2(Math.abs(a1-h),Math.abs(a2-d))
if(typeof a6!=="number")return A.a4(a6)
a3.r=i*a6
a3.e=a9
if(!a3.x){b.a(a3);++b2.d
b2.a0(a3)
a3.x=!0}}}}},
an(a,b,c,d,e,f){var s,r,q=a+c,p=b+d
if(!e.k(q,p))return null
if(q===f.a&&p===f.b){if(c!==0&&d!==0)if(!e.k(q,b)&&!e.k(a,p))return null
return new A.j(q,p)}s=c!==0
if(s&&d!==0){s=q-c
if(!(e.k(s,p+d)&&!e.k(s,p))){s=p-d
s=e.k(q+c,s)&&!e.k(q,s)}else s=!0
if(s)return new A.j(q,p)
if(this.an(q,p,c,0,e,f)!=null||this.an(q,p,0,d,e,f)!=null)return new A.j(q,p)}else if(s){s=q+c
r=p+1
if(!(e.k(s,r)&&!e.k(q,r))){r=p-1
s=e.k(s,r)&&!e.k(q,r)}else s=!0
if(s)return new A.j(q,p)}else{s=q+1
r=p+d
if(!(e.k(s,r)&&!e.k(s,p))){s=q-1
s=e.k(s,r)&&!e.k(s,p)}else s=!0
if(s)return new A.j(q,p)}return this.an(q,p,c,d,e,f)}}
A.dp.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.f+a.r,b.f+b.r)},
$S:2}
A.du.prototype={
W(a,b,c,d,e){var s,r,q,p=++e.d,o=A.a8(new A.dv(),t.A),n=null,m=null
try{n=e.p(a,b)
m=e.p(c,d)}catch(s){p=A.d([],t._)
return p}n.R(p)
m.I(p)
if(!n.c||!m.c)return A.d([],t._)
n.f=0
p=n
r=this.c.$2(Math.abs(a-m.a),Math.abs(b-m.b))
if(typeof r!=="number")return A.a4(r)
p.r=this.d*r
n.x=!0
o.h(0,n)
for(;o.c!==0;){q=o.P()
q.w=!0
if(q.H(0,m))return A.ag(m)
this.bP(q,e,m,o)}return A.d([],t._)},
bP(a,a0,a1,a2){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b
t.t.a(a2)
s=a0.d
r=a.a
q=a.b
p=a.e
o=A.hi(t.dL)
n=a1.a
if(r!==n){m=B.b.gad(n-r)
if(a0.k(r+m,q))o.h(0,new A.j(m,0))}n=a1.b
if(q!==n){l=B.b.gad(n-q)
if(a0.k(r,q+l))o.h(0,new A.j(0,l))}if(p!=null){k=p.a
j=p.b
i=B.b.gad(r-k)
h=B.b.gad(q-j)
if(i!==0){if(a0.k(r+i,q))o.h(0,new A.j(i,0))
n=q+1
if(a0.k(r,n)&&!a0.k(r-i,n))o.h(0,B.F)
n=q-1
if(a0.k(r,n)&&!a0.k(r-i,n))o.h(0,B.G)}else{if(a0.k(r,q+h))o.h(0,new A.j(0,h))
n=r+1
if(a0.k(n,q)&&!a0.k(n,q-h))o.h(0,B.H)
n=r-1
if(a0.k(n,q)&&!a0.k(n,q-h))o.h(0,B.V)}}else{g=a0.bq(a,!1)
for(n=g.length,f=0;f<g.length;g.length===n||(0,A.l)(g),++f){e=g[f]
o.h(0,new A.j(e.a-r,e.b-q))}}for(n=A.ja(o,o.r,o.$ti.c),d=n.$ti.c;n.C();){c=n.d
if(c==null)c=d.a(c)
b=this.bc(r,q,c.a,c.b,a0,a1)
if(b!=null)this.bC(b,a,a1,a2,a0,s)}},
bC(a,b,c,d,e,f){var s,r,q,p,o
t.t.a(d)
s=a.a
r=a.b
q=e.p(s,r)
q.I(f)
if(q.w)return
p=b.f+(Math.abs(Math.abs(b.a-s))+Math.abs(Math.abs(b.b-r)))
if(p<q.f||!q.x){q.f=p
o=this.c.$2(Math.abs(s-c.a),Math.abs(r-c.b))
if(typeof o!=="number")return A.a4(o)
q.r=this.d*o
q.e=b
if(!q.x){d.h(0,q)
q.x=!0}}},
bc(a,b,c,d,e,f){var s,r,q=a+c,p=b+d
if(!e.k(q,p)){if(c!==0){s=b+1
if(!(e.k(a,s)&&!e.k(a-c,s))){s=b-1
s=e.k(a,s)&&!e.k(a-c,s)}else s=!0
if(s)return new A.j(a,b)}else{s=a+1
if(!(e.k(s,b)&&!e.k(s,b-d))){s=a-1
s=e.k(s,b)&&!e.k(s,b-d)}else s=!0
if(s)return new A.j(a,b)}return null}s=q===f.a
if(s&&p===f.b)return new A.j(q,p)
r=c!==0
if(r&&s)return new A.j(q,p)
if(d!==0&&p===f.b)return new A.j(q,p)
if(r){s=b+1
if(!(!e.k(a,s)&&e.k(q,s))){s=b-1
s=!e.k(a,s)&&e.k(q,s)}else s=!0
if(s)return new A.j(q,p)}else{s=a+1
if(!(!e.k(s,b)&&e.k(s,p))){s=a-1
s=!e.k(s,b)&&e.k(s,p)}else s=!0
if(s)return new A.j(q,p)}return this.bc(q,p,c,d,e,f)}}
A.dv.prototype={
$2(a,b){var s=t.A
s.a(a)
s.a(b)
return B.c.S(a.f+a.r,b.f+b.r)},
$S:2}
A.dg.prototype={
bx(a,b,c,d){var s,r,q,p,o=this,n=o.a
if(n<=0||o.b<=0)throw A.c(A.bc("Grid dimensions must be positive.",null))
if(c<1)throw A.c(A.bc("Node weight cannot be less than 1.0.",null))
s=o.b
r=J.hd(s,t.b)
for(q=t.A,p=0;p<s;++p)r[p]=A.iT(n,new A.di(c,d,p),!1,q)
t.w.a(r)
o.c!==$&&A.kB()
o.sbz(r)},
p(a,b){var s,r=this
if(!r.bm(a,b))throw A.c(A.hq("Coordinates ("+a+", "+b+") are outside grid bounds ("+r.a+" x "+r.b+")."))
s=r.c
s===$&&A.f()
if(!(b>=0&&b<s.length))return A.e(s,b)
s=s[b]
if(!(a>=0&&a<s.length))return A.e(s,a)
return s[a]},
bm(a,b){return a>=0&&a<this.a&&b>=0&&b<this.b},
k(a,b){var s
if(this.bm(a,b)){s=this.c
s===$&&A.f()
if(!(b>=0&&b<s.length))return A.e(s,b)
s=s[b]
if(!(a>=0&&a<s.length))return A.e(s,a)
s=s[a].c}else s=!1
return s},
M(a,b,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this
if(!a.c)return A.d([],t._)
s=A.d([],t._)
r=a.a
q=a.b
p=q-1
o=c.k(r,p)
if(o){n=c.c
n===$&&A.f()
if(!(p>=0&&p<n.length))return A.e(n,p)
n=n[p]
if(!(r<n.length))return A.e(n,r)
B.a.h(s,n[r])}n=q+1
m=c.k(r,n)
if(m){l=c.c
l===$&&A.f()
if(!(n<l.length))return A.e(l,n)
l=l[n]
if(!(r<l.length))return A.e(l,r)
B.a.h(s,l[r])}l=r+1
k=c.k(l,q)
if(k){j=c.c
j===$&&A.f()
if(!(q<j.length))return A.e(j,q)
j=j[q]
if(!(l<j.length))return A.e(j,l)
B.a.h(s,j[l])}j=r-1
i=c.k(j,q)
if(i){h=c.c
h===$&&A.f()
if(!(q<h.length))return A.e(h,q)
h=h[q]
if(!(j>=0&&j<h.length))return A.e(h,j)
B.a.h(s,h[j])}if(!b)return s
if(a0){g=o&&k
f=m&&k
e=m&&i
d=o&&i}else{g=c.k(l,p)
f=c.k(l,n)
e=c.k(j,n)
d=c.k(j,p)}if(g&&c.k(l,p)){h=c.c
h===$&&A.f()
if(!(p>=0&&p<h.length))return A.e(h,p)
h=h[p]
if(!(l<h.length))return A.e(h,l)
B.a.h(s,h[l])}if(f&&c.k(l,n)){h=c.c
h===$&&A.f()
if(!(n<h.length))return A.e(h,n)
h=h[n]
if(!(l<h.length))return A.e(h,l)
B.a.h(s,h[l])}if(e&&c.k(j,n)){l=c.c
l===$&&A.f()
if(!(n<l.length))return A.e(l,n)
n=l[n]
if(!(j>=0&&j<n.length))return A.e(n,j)
B.a.h(s,n[j])}if(d&&c.k(j,p)){n=c.c
n===$&&A.f()
if(!(p>=0&&p<n.length))return A.e(n,p)
p=n[p]
if(!(j>=0&&j<p.length))return A.e(p,j)
B.a.h(s,p[j])}return s},
bq(a,b){return this.M(a,b,!1)},
sbz(a){this.c=t.w.a(a)}}
A.di.prototype={
$1(a){return new A.x(a,this.c,!0,this.a)},
$S:25}
A.x.prototype={
I(a){if(this.y!==a){this.R(a)
return!0}return!1},
R(a){var s=this
s.r=s.f=0
s.e=null
s.x=s.w=!1
s.y=a},
n(a){var s=this
return"Node("+s.a+", "+s.b+", walkable: "+s.c+", weight: "+s.d+")"},
H(a,b){var s,r=this
if(b==null)return!1
if(r!==b)s=b instanceof A.x&&A.N(r)===A.N(b)&&r.a===b.a&&r.b===b.b
else s=!0
return s},
gB(a){return B.b.gB(this.a)^B.b.gB(this.b)},
sag(a){this.r=A.aM(a)}}
A.dx.prototype={
ab(a,b){var s=b.d
return Math.abs(a.a-b.a)===1&&Math.abs(a.b-b.b)===1?s*1.414213562373095:s}}
A.q.prototype={}
A.eI.prototype={
a4(a,b){var s=this.b,r=A.F(s).i("aa(1)").a(new A.eJ(b))
s.$flags&1&&A.A(s,16)
B.a.bU(s,r,!0)},
ca(){var s,r,q,p,o,n,m=new Float64Array(2),l=new A.a(m),k=this.b,j=k.length
if(j===0)return l
for(s=this.a,r=0;r<k.length;k.length===j||(0,A.l)(k),++r){q=k[r]
p=q.b
if(p===0)continue
o=q.a.J(s)
if(p!==1){n=o.a
m[0]=m[0]+n[0]*p
m[1]=m[1]+n[1]*p}else l.h(0,o)}A.j4(l,s.f)
return l}}
A.eJ.prototype={
$1(a){return t.fO.a(a).a===this.a},
$S:26}
A.D.prototype={}
A.dF.prototype={
bb(a){var s=a.a,r=s[0],q=this.b
q===$&&A.f()
return new A.j(B.c.Z(r*q),B.c.Z(s[1]*q))},
h(a,b){var s=this.bb(b.c),r=(s.a*73856093^s.b*19349663)>>>0
J.h2(this.c.bn(r,new A.dG()),b)
this.d.l(0,b,r)},
co(a){var s,r,q,p=this,o=p.bb(a.c),n=(o.a*73856093^o.b*19349663)>>>0,m=p.d,l=m.j(0,a)
if(l!==n){if(l!=null){s=p.c
r=s.j(0,l)
q=r==null
if(!q)J.it(r,a)
if(!q&&J.ir(r))s.a4(0,l)}J.h2(p.c.bn(n,new A.dH()),a)
m.l(0,a,n)}},
aQ(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(b<0)return A.d([],t.g)
s=A.hi(t.E)
r=b*b
q=a.a
p=q[0]
o=this.b
o===$&&A.f()
n=B.c.Z((p-b)*o)
m=B.c.Z((q[0]+b)*o)
l=B.c.Z((q[1]-b)*o)
k=B.c.Z((q[1]+b)*o)
for(q=this.c,j=l;j<=k;++j)for(p=j*19349663,i=n;i<=m;++i){h=q.j(0,(i*73856093^p)>>>0)
if(h!=null)for(o=J.ba(h);o.C();){g=o.gG()
if(g.c.af(a)<=r)s.h(0,g)}}return A.a9(s,!0,s.$ti.c)}}
A.dG.prototype={
$0(){return A.d([],t.g)},
$S:12}
A.dH.prototype={
$0(){return A.d([],t.g)},
$S:12}
A.a.prototype={
m(a,b){var s=this.a
s.$flags&2&&A.A(s)
s[0]=a
s[1]=b},
ai(){var s=this.a
s.$flags&2&&A.A(s)
s[0]=0
s[1]=0},
F(a){var s=a.a,r=this.a,q=s[1]
r.$flags&2&&A.A(r)
r[1]=q
r[0]=s[0]},
n(a){var s=this.a
return"["+A.p(s[0])+","+A.p(s[1])+"]"},
H(a,b){var s,r,q
if(b==null)return!1
if(b instanceof A.a){s=this.a
r=s[0]
q=b.a
s=r===q[0]&&s[1]===q[1]}else s=!1
return s},
gB(a){return A.hl(this.a)},
aw(a){var s=new A.a(new Float64Array(2))
s.F(this)
s.aP()
return s},
u(a,b){var s=new A.a(new Float64Array(2))
s.F(this)
s.a6(b)
return s},
O(a,b){var s=new A.a(new Float64Array(2))
s.F(this)
s.h(0,b)
return s},
aU(a,b){var s=new A.a(new Float64Array(2))
s.F(this)
s.A(1/b)
return s},
E(a,b){var s=new A.a(new Float64Array(2))
s.F(this)
s.A(b)
return s},
sq(a,b){var s,r,q
if(b===0)this.ai()
else{s=Math.sqrt(this.gt())
if(s===0)return
s=b/s
r=this.a
q=r[0]
r.$flags&2&&A.A(r)
r[0]=q*s
r[1]=r[1]*s}},
gq(a){return Math.sqrt(this.gt())},
gt(){var s=this.a,r=s[0]
s=s[1]
return r*r+s*s},
N(){var s,r,q,p=Math.sqrt(this.gt())
if(p===0)return 0
s=1/p
r=this.a
q=r[0]
r.$flags&2&&A.A(r)
r[0]=q*s
r[1]=r[1]*s
return p},
T(){var s=new A.a(new Float64Array(2))
s.F(this)
s.N()
return s},
af(a){var s=this.a,r=a.a,q=s[0]-r[0],p=s[1]-r[1]
return q*q+p*p},
ar(a){var s=a.a,r=this.a
return r[0]*s[0]+r[1]*s[1]},
h(a,b){var s=b.a,r=this.a,q=r[0],p=s[0]
r.$flags&2&&A.A(r)
r[0]=q+p
r[1]=r[1]+s[1]},
a6(a){var s=a.a,r=this.a,q=r[0],p=s[0]
r.$flags&2&&A.A(r)
r[0]=q-p
r[1]=r[1]-s[1]},
A(a){var s=this.a,r=s[1]
s.$flags&2&&A.A(s)
s[1]=r*a
s[0]=s[0]*a},
aP(){var s=this.a,r=s[1]
s.$flags&2&&A.A(s)
s[1]=-r
s[0]=-s[0]},
saS(a){var s=this.a
s.$flags&2&&A.A(s)
s[0]=a},
saT(a){var s=this.a
s.$flags&2&&A.A(s)
s[1]=a}}
A.fz.prototype={}
A.bJ.prototype={}
A.cN.prototype={}
A.cP.prototype={}
A.eW.prototype={
$1(a){return this.a.$1(t.m.a(a))},
$S:3}
A.ay.prototype={}
A.fg.prototype={
$2(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g=this,f=A.a9(B.z,!0,t.g6)
B.a.bu(f,g.a)
for(s=f.length,r=g.b-1,q=g.c-1,p=g.d,o=p.a,n=p.b,m=0;m<f.length;f.length===s||(0,A.l)(f),++m){l=f[m]
k=l.j(0,"dx")
k.toString
j=a+k
k=l.j(0,"dy")
k.toString
i=b+k
k=!1
if(j>0)if(j<r)if(i>0)if(i<q){k=!1
if(j<o)k=i<n
if(k){k=p.c
k===$&&A.f()
if(!(i<k.length))return A.e(k,i)
k=k[i]
if(!(j<k.length))return A.e(k,j)
k=k[j].c}else k=!1
k=!k}if(k){p.p(j,i).c=!0
k=l.j(0,"dx")
k.toString
k=B.b.V(k,2)
h=l.j(0,"dy")
h.toString
p.p(a+k,b+B.b.V(h,2)).c=!0
g.$2(j,i)}}},
$S:28}
A.cA.prototype={}
A.fj.prototype={
$1(a){return t.k.a(a)!=null},
$S:35}
A.fk.prototype={
$1(a){t.k.a(a)
return new A.I(a.a,a.b,t.D)},
$S:29}
A.fv.prototype={
$0(){var s,r,q,p,o=this,n=o.b,m=$.fr.j(0,n),l=A.aD(o.c.value),k=o.a,j=A.kg(k.a,l)
k.b=j
$.fr.l(0,n,j)
n=k.b
s=n.c
r=n.d
q=r?"Yes":"No"
n=A.p(r?n.a.length:"N/A")
p=k.b
o.d.textContent="Algorithm: "+s+"\nPath Found: "+q+"\nPath Length: "+n+"\nNodes Visited: "+p.e+" (Note: Count might be 0 if unavailable)\nTime Taken: "+A.p(p.b.a/1000)+" ms\n"
n=o.e
if(m!=null)n.textContent="(Previous: "+m.c+")"
else n.textContent=""
n=o.f
if(n!=null)A.ky(n,k.a,k.b,m)},
$S:1}
A.fs.prototype={
$1(a){this.a.$0()},
$S:3}
A.fu.prototype={
$0(){var s,r=this,q=r.b.$0()
r.a.a=q
s=r.c
$.ib.l(0,s,q)
$.fr.l(0,s,null)
r.d.textContent=""
r.e.$0()},
$S:1}
A.ft.prototype={
$1(a){return this.a.$0()},
$S:3}
A.a7.prototype={
ak(a,b){var s=this.x
s===$&&A.f()
B.a.h(s.b,new A.D(a,b))
this.y.l(0,A.N(a),new A.G(a,b))},
D(a){return this.ak(a,1)},
a5(a){var s
A.c4(a,t.s,"T","getBehavior")
s=this.y.j(0,A.ab(a))
s=s==null?null:s.a
return a.i("0?").a(s)},
$ibb:1}
A.r.prototype={}
A.dI.prototype={
bY(){var s,r,q=this,p="click",o=q.c
o===$&&A.f()
s=t.a
r=s.i("~(1)?")
s=s.c
A.aA(o,"change",r.a(new A.dL(q)),!1,s)
o=q.f
o===$&&A.f()
A.aA(o,p,r.a(new A.dM(q)),!1,s)
o=q.a
o===$&&A.f()
A.aA(o,p,r.a(new A.dN(q)),!1,s)
o=q.r
o===$&&A.f()
A.aA(o,p,r.a(new A.dO(q)),!1,s)
o=q.w
o===$&&A.f()
A.aA(o,"change",r.a(new A.dP(q)),!1,s)},
bh(a){var s,r=this
r.cy=a
s=r.c
s===$&&A.f()
s.value=a
r.bi(r.cy,!0)
r.bk()},
bH(){var s,r,q,p,o,n=this
n.cx.X(0)
for(s=n.y,r=s.length,q=0;q<s.length;s.length===r||(0,A.l)(s),++q){p=s[q]
o=p.x
o===$&&A.f()
B.a.X(o.b)
p.y.X(0)}B.a.X(s)
B.a.X(n.z)
B.a.X(n.ch)
n.as=n.CW=n.ay=n.ax=n.at=n.Q=null},
bi(b3,b4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b0,b1,b2=this
b2.bH()
s=new Float64Array(2)
r=new A.a(new Float64Array(2))
r.m(800,600)
b2.ay=new A.ah(new A.a(s),r)
switch(b3){case"Seek":s=new A.a(new Float64Array(2))
s.m(600,300)
b2.at=s
s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(200,300)
q=A.C(s,200,150,r,10)
r=b2.at
r.toString
q.D(new A.aK(r))
B.a.h(b2.y,q)
break
case"Flee":s=new A.a(new Float64Array(2))
s.m(400,300)
b2.at=s
s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(200,300)
q=A.C(s,200,150,r,10)
r=b2.at
r.toString
q.D(new A.bi(r))
s=new A.a(new Float64Array(2))
s.m(50,50)
r=new A.a(new Float64Array(2))
r.m(750,550)
q.ak(new A.r(0.5,new A.ah(s,r),30),2)
B.a.h(b2.y,q)
break
case"Arrival":s=new A.a(new Float64Array(2))
s.m(600,300)
b2.at=s
s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(200,300)
q=A.C(s,200,150,r,10)
r=b2.at
r.toString
q.D(new A.aQ(r,100,0.010000000000000002))
B.a.h(b2.y,q)
break
case"Wander":s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(400,300)
q=A.C(s,200,150,r,10)
q.D(A.an(3.141592653589793,50,25))
r=b2.ay
r.toString
q.D(new A.r(0.5,r,30))
B.a.h(b2.y,q)
break
case"Pursuit":s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(560,420)
r=A.C(s,200,100,r,10)
r.b="green"
b2.ax=r
r.D(A.an(1.5707963267948966,40,20))
r=b2.ax
r.toString
s=b2.ay
s.toString
r.D(new A.r(0.5,s,30))
s=b2.b
r=new A.a(new Float64Array(2))
r.m(240,180)
p=A.C(s,200,150,r,10)
p.b="red"
r=b2.ax
r.toString
p.D(new A.cD(r))
r=b2.ay
r.toString
p.D(new A.r(0.5,r,30))
r=b2.y
B.a.h(r,p)
s=b2.ax
s.toString
B.a.h(r,s)
break
case"Evade":s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(240,180)
r=A.C(s,200,120,r,10)
r.b="red"
b2.ax=r
s=new A.a(new Float64Array(2))
s.m(400,300)
r.D(new A.aK(s))
s=b2.ax
s.toString
r=b2.ay
r.toString
s.D(new A.r(0.5,r,30))
r=b2.b
s=new A.a(new Float64Array(2))
s.m(480,360)
o=A.C(r,200,150,s,10)
o.b="blue"
s=b2.ax
s.toString
o.D(new A.bh(s))
s=b2.ay
s.toString
o.D(new A.r(0.5,s,30))
s=b2.y
B.a.h(s,o)
r=b2.ax
r.toString
B.a.h(s,r)
break
case"Offset Pursuit":s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(560,420)
r=A.C(s,200,100,r,10)
r.b="green"
b2.ax=r
r.D(A.an(2.5132741228718345,60,30))
r=b2.ax
r.toString
s=b2.ay
s.toString
r.D(new A.r(0.5,s,30))
s=b2.b
r=new A.a(new Float64Array(2))
r.m(240,180)
n=A.C(s,200,150,r,10)
n.b="purple"
r=b2.ax
r.toString
s=new A.a(new Float64Array(2))
s.m(-50,0)
n.D(new A.bC(r,s))
s=b2.ay
s.toString
n.D(new A.r(0.5,s,30))
s=b2.y
B.a.h(s,n)
r=b2.ax
r.toString
B.a.h(s,r)
break
case"Obstacle Avoidance":s=b2.z
r=new A.a(new Float64Array(2))
r.m(320,300)
B.a.h(s,new A.aH(r,30))
r=new A.a(new Float64Array(2))
r.m(480,120)
B.a.h(s,new A.aH(r,40))
r=new A.a(new Float64Array(2))
r.m(560,420)
B.a.h(s,new A.aH(r,25))
r=b2.b
r===$&&A.f()
m=new A.a(new Float64Array(2))
m.m(50,400)
q=A.C(r,200,150,m,10)
r=new A.a(new Float64Array(2))
r.m(750,100)
b2.at=r
q.D(new A.aK(r))
q.ak(A.fF(300,90,s),2.5)
s=q.a5(t.R)
if(s!=null){r=b2.at
r.toString
s.a=r}B.a.h(b2.y,q)
break
case"Path Following":s=new A.a(new Float64Array(2))
s.m(80,120)
r=new A.a(new Float64Array(2))
r.m(320,480)
m=new A.a(new Float64Array(2))
m.m(640,180)
l=new A.a(new Float64Array(2))
l.m(720,540)
b2.Q=A.hm(!1,A.d([s,r,m,l],t.e),20)
l=b2.b
l===$&&A.f()
s=new A.a(new Float64Array(2))
s.m(80,60)
q=A.C(l,200,150,s,10)
s=b2.Q
s.toString
q.D(new A.a0(s,50,new A.a(new Float64Array(2))))
s=b2.Q.a
if(s.length!==0)q.d=J.iq(B.a.gY(s),q.c).T().E(0,1)
B.a.h(b2.y,q)
break
case"Wall Following":s=b2.ch
r=new A.a(new Float64Array(2))
r.m(100,100)
m=new A.a(new Float64Array(2))
m.m(700,100)
B.a.h(s,new A.az(r,m))
r=new A.a(new Float64Array(2))
r.m(700,100)
m=new A.a(new Float64Array(2))
m.m(700,500)
B.a.h(s,new A.az(r,m))
r=new A.a(new Float64Array(2))
r.m(700,500)
m=new A.a(new Float64Array(2))
m.m(100,500)
B.a.h(s,new A.az(r,m))
r=new A.a(new Float64Array(2))
r.m(100,500)
m=new A.a(new Float64Array(2))
m.m(100,100)
B.a.h(s,new A.az(r,m))
m=b2.b
m===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(150,150)
q=A.C(m,200,150,r,10)
q.D(A.eR(15,60,1000,s))
q.ak(A.an(4.71238898038469,10,5),0.2)
B.a.h(b2.y,q)
break
case"Containment":s=new A.a(new Float64Array(2))
s.m(100,100)
r=new A.a(new Float64Array(2))
r.m(700,500)
b2.ay=new A.ah(s,r)
r=b2.b
r===$&&A.f()
s=new A.a(new Float64Array(2))
s.m(400,300)
q=A.C(r,200,150,s,10)
q.D(A.an(3.141592653589793,50,25))
s=b2.ay
s.toString
q.D(new A.r(0.5,s,30))
B.a.h(b2.y,q)
break
case"Separation":case"Cohesion":case"Alignment":case"Flocking":b2.bZ(b3)
break
case"Leader Following":b2.c_()
break
case"Flow Field Following":k=B.b.bl(40)
j=B.b.bl(30)
i=800/k
h=A.dh(k,j)
for(g=B.b.V(k,4),s=B.b.V(k*3,4);g<s;++g){r=B.b.V(j,2)
h.p(g,r).c=!1
if(B.b.ac(g,5)===0)h.p(g,r-1).c=!1}for(g=B.b.V(j,4),s=B.b.V(j*3,4);g<s;++g){r=B.b.V(k,2)
h.p(r,g).c=!1
if(B.b.ac(g,5)===0)h.p(r-1,g).c=!1}f=k-2
e=j-2
if(!h.k(f,e))h.p(f,e).c=!0
new A.cf(!0,!1,A.a3(),1).W(f,e,0,0,h)
b2.CW=A.iF(i,k,new A.a(new Float64Array(2)),j)
for(d=0;d<j;++d)for(s=(d+0.5)*i,c=0;c<k;++c){b=h.p(c,d)
r=b.c
if(!r){r=b2.CW
r.toString
r.aV(c,d,new A.a(new Float64Array(2)))
continue}a=h.M(b,!0,!0)
for(r=a.length,a0=null,a1=1/0,a2=0;a2<r;++a2){a3=a[a2]
m=!1
if(a3.c){m=a3.f
m=m>=0&&m<a1}if(m){a1=a3.f
a0=a3}}if(a0!=null){r=new Float64Array(2)
r[0]=(c+0.5)*i
r[1]=s
m=a0.a
l=a0.b
a4=new Float64Array(2)
a4[0]=(m+0.5)*i
a4[1]=(l+0.5)*i
m=new Float64Array(2)
m[1]=a4[1]
m[0]=a4[0]
new A.a(m).a6(new A.a(r))
r=new Float64Array(2)
a5=new A.a(r)
r[1]=m[1]
r[0]=m[0]
a5.N()}else a5=new A.a(new Float64Array(2))
b2.CW.aV(c,d,a5)}for(s=i*0.6,r=b2.y,m=h.a,l=h.b,g=0;g<20;++g){a4=b2.b
a4===$&&A.f()
a6=B.d.K()
a7=B.d.K()
a8=new Float64Array(2)
a8[0]=50+a6*700
a8[1]=50+a7*500
q=A.C(a4,180,120,new A.a(a8),6)
a9=B.c.Z(q.c.a[0]/i)
b0=B.c.Z(q.c.a[1]/i)
if(a9>=0&&a9<m&&b0>=0&&b0<l){a4=h.c
a4===$&&A.f()
if(!(b0>=0&&b0<a4.length))return A.e(a4,b0)
a4=a4[b0]
if(!(a9>=0&&a9<a4.length))return A.e(a4,a9)
a4=a4[a9].c}else a4=!1
if(!a4){a4=B.d.K()
a6=B.d.K()
a7=new Float64Array(2)
a7[0]=50+a4*700
a7[1]=50+a6*500
q.c=new A.a(a7)}a4=b2.CW
a4.toString
a4=new A.ci(a4,s)
a6=q.x
a6===$&&A.f()
B.a.h(a6.b,new A.D(a4,1))
a7=q.y
a7.l(0,A.N(a4),new A.G(a4,1))
a4=b2.ay
a4.toString
a4=new A.r(0.5,a4,30)
B.a.h(a6.b,new A.D(a4,1))
a7.l(0,A.N(a4),new A.G(a4,1))
B.a.h(r,q)}break
case"Unaligned Collision Avoidance":s=new A.a(new Float64Array(2))
s.m(50,50)
r=new A.a(new Float64Array(2))
r.m(750,550)
b2.ay=new A.ah(s,r)
b2.as=A.hu(30)
for(s=b2.y,g=0;g<15;++g){r=b2.b
r===$&&A.f()
m=B.d.K()
l=B.d.K()
a4=new Float64Array(2)
a4[0]=100+m*600
a4[1]=100+l*400
q=A.C(r,150,100+B.d.K()*50,new A.a(a4),8)
r=A.an(1.5707963267948966+B.d.K()*3.141592653589793,40,20)
m=q.x
m===$&&A.f()
B.a.h(m.b,new A.D(r,1))
l=q.y
l.l(0,A.N(r),new A.G(r,1))
r=b2.as
r.toString
r=new A.a1(r,q.w*2+5)
B.a.h(m.b,new A.D(r,1.5))
l.l(0,A.N(r),new A.G(r,1.5))
r=b2.ay
r.toString
r=new A.r(0.5,r,30)
B.a.h(m.b,new A.D(r,1))
l.l(0,A.N(r),new A.G(r,1))
B.a.h(s,q)
b2.as.h(0,q)}break
default:s=b2.b
s===$&&A.f()
r=new A.a(new Float64Array(2))
r.m(400,300)
B.a.h(b2.y,A.C(s,200,150,r,10))}if(b3!=="Containment"&&b3!=="Wall Following")for(s=b2.y,r=s.length,m=t.G,a2=0;a2<s.length;s.length===r||(0,A.l)(s),++a2){q=s[a2]
if(q.a5(m)==null&&b2.ay!=null){l=q.y
b1=l.a>1?0.5:1
a4=b2.ay
a4.toString
a4=new A.r(0.5,a4,30)
a6=q.x
a6===$&&A.f()
B.a.h(a6.b,new A.D(a4,b1))
l.l(0,A.N(a4),new A.G(a4,b1))}}b2.c4()},
bZ(a){var s,r,q,p,o,n,m,l,k,j,i=this,h=new A.a(new Float64Array(2))
h.m(50,50)
s=new A.a(new Float64Array(2))
s.m(750,550)
i.ay=new A.ah(h,s)
i.as=A.hu(100)
for(h=i.y,s=a!=="Alignment",r=a!=="Cohesion",q=a!=="Separation",p=a==="Flocking",o=0;o<30;++o){n=i.b
n===$&&A.f()
m=B.d.K()
l=B.d.K()
k=new Float64Array(2)
k[0]=100+m*600
k[1]=100+l*400
j=A.C(n,250,180,new A.a(k),5)
k=B.d.K()
n=B.d.K()
m=new Float64Array(2)
l=new A.a(m)
m[0]=k*2-1
m[1]=n*2-1
l.N()
l.A(j.e*0.5)
j.d=l
if(!q||p){n=i.as
n.toString
n=new A.a1(n,25)
m=j.x
m===$&&A.f()
B.a.h(m.b,new A.D(n,1.5))
j.y.l(0,A.N(n),new A.G(n,1.5))}if(!r||p){n=i.as
n.toString
n=new A.a_(n,100)
m=j.x
m===$&&A.f()
B.a.h(m.b,new A.D(n,1))
j.y.l(0,A.N(n),new A.G(n,1))}if(!s||p){n=i.as
n.toString
n=new A.Z(n,100)
m=j.x
m===$&&A.f()
B.a.h(m.b,new A.D(n,1))
j.y.l(0,A.N(n),new A.G(n,1))}n=i.ay
n.toString
n=new A.r(0.5,n,30)
m=j.x
m===$&&A.f()
B.a.h(m.b,new A.D(n,1))
j.y.l(0,A.N(n),new A.G(n,1))
B.a.h(h,j)}},
c_(){var s,r,q,p,o,n,m,l,k,j=this,i=new A.a(new Float64Array(2))
i.m(50,50)
s=new A.a(new Float64Array(2))
s.m(750,550)
j.ay=new A.ah(i,s)
s=j.b
s===$&&A.f()
i=new A.a(new Float64Array(2))
i.m(400,300)
r=A.C(s,200,120,i,12)
r.b="orange"
r.D(A.an(2.199114857512855,80,40))
i=j.ay
i.toString
r.D(new A.r(0.5,i,30))
i=j.y
B.a.h(i,r)
for(q=0;q<15;++q){s=j.b
p=r.c
o=B.d.K()
n=B.d.K()
m=new Float64Array(2)
m[0]=o*60-30
m[1]=n*60-30
o=new Float64Array(2)
n=new A.a(o)
l=p.a
o[1]=l[1]
o[0]=l[0]
n.h(0,new A.a(m))
k=A.C(s,280,190,n,6)
k.b="teal"
n=A.dq(null,r,50,30,10,null)
s=k.x
s===$&&A.f()
B.a.h(s.b,new A.D(n,1))
m=k.y
m.l(0,A.N(n),new A.G(n,1))
n=j.ay
n.toString
n=new A.r(0.5,n,30)
B.a.h(s.b,new A.D(n,0.8))
m.l(0,A.N(n),new A.G(n,0.8))
B.a.h(i,k)}},
bk(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=this,a3="Prediction Distance",a4="Cohesion Radius",a5="Alignment Radius",a6=a2.d
a6===$&&A.f()
a6.innerHTML=""
s=$.ip().j(0,a2.cy)
a6=s==null
r=t.m
q=a2.d
if(!a6){p=self
o=r.a(r.a(p.document).createElement("p"))
r.a(o.style).fontWeight="bold"
o.textContent="Description:"
q.append(o)
q=a2.d
o=r.a(r.a(p.document).createElement("p"))
r.a(o.style).fontSize="0.9em"
r.a(o.style).marginTop="2px"
r.a(o.style).marginBottom="10px"
o.textContent=s.a
q.append(o)
q=a2.d
o=r.a(r.a(p.document).createElement("p"))
r.a(o.style).fontWeight="bold"
o.textContent="Interaction:"
q.append(o)
q=a2.d
o=r.a(r.a(p.document).createElement("p"))
r.a(o.style).fontSize="0.9em"
r.a(o.style).marginTop="2px"
r.a(o.style).marginBottom="15px"
o.textContent=s.b
q.append(o)}else{o=r.a(r.a(self.document).createElement("p"))
o.textContent="Info not available for this behavior."
q.append(o)}q=a2.d
p=self
q.append(r.a(r.a(p.document).createElement("hr")))
q=a2.y
n=q.length
if(n<=1)if(n===1){n=a2.ax
n=n!=null&&B.a.aa(q,n)
m=n}else m=!1
else m=!0
n=a2.x
n===$&&A.f()
n=r.a(n.style)
l=m?"block":"none"
n.display=l
n=q.length===0
if(n&&a2.ax==null){if(a6){a6=a2.d
o=r.a(r.a(p.document).createElement("p"))
o.textContent="No agent selected or scenario not fully implemented."
a6.append(o)}r.a(a2.x.style).display="none"
return}k=!n?B.a.gY(q):a2.ax
if(k==null)return
a6=a2.d
o=r.a(r.a(p.document).createElement("h4"))
o.textContent="Agent Settings"
a6.append(o)
a2.v(a2.d,"Max Speed",k.e,10,500,1,new A.ec(a2))
a2.v(a2.d,"Max Force",k.f,10,500,1,new A.ed(a2))
a2.v(a2.d,"Mass",k.r,0.1,10,0.1,new A.ee(a2))
a2.v(a2.d,"Radius",k.w,1,50,1,new A.ep(a2))
a6=a2.d
o=r.a(r.a(p.document).createElement("h4"))
o.textContent="Behavior: "+a2.cy
a6.append(o)
j=new A.eF()
i=new A.eG()
h=new A.eH(a2,i)
g=!0
switch(a2.cy){case"Arrival":f=j.$1$1(k,t.J)
g=f!=null
if(g)a2.v(a2.d,"Slowing Radius",f.b,5,200,1,new A.ey(f))
break
case"Wander":f=j.$1$1(k,t.p)
e=f!=null
if(e){a2.v(a2.d,"Wander Distance",f.a,10,200,1,new A.ez(i,k))
a2.v(a2.d,"Wander Radius",f.b,5,100,1,new A.eA(i,k))
a2.v(a2.d,"Angle Change/s",f.c,0.1,12.566370614359172,0.1,new A.eB(i,k))}d=j.$1$1(k,t.G)
if(d!=null){a2.v(a2.d,"Contain Predict",d.b,5,100,1,new A.eC(i,k))
a2.v(a2.d,"Contain Force Incr",d.d,0.1,2,0.1,new A.eD(i,k))}else g=e
break
case"Pursuit":case"Evade":a6=a2.d
o=r.a(r.a(p.document).createElement("p"))
o.textContent="No specific parameters."
a6.append(o)
break
case"Offset Pursuit":f=j.$1$1(B.a.gY(q),t.gu)
g=f!=null
if(g){a6=a2.d
n=f.b.a
a2.v(a6,"Offset X",n[0],-100,100,1,new A.eE(f))
a2.v(a2.d,"Offset Y",n[1],-100,100,1,new A.ef(f))}break
case"Obstacle Avoidance":f=j.$1$1(k,t.f)
g=f!=null
if(g){a2.v(a2.d,"Detection Length",f.b,10,200,1,new A.eg(i,k))
a2.v(a2.d,"Avoidance Force",f.c,10,500,5,new A.eh(i,k))}break
case"Path Following":f=j.$1$1(k,t.j)
if(f!=null&&a2.Q!=null){a2.v(a2.d,"Path Radius",a2.Q.b,5,50,1,new A.ei(a2,i,k))
a2.v(a2.d,a3,f.b,10,150,1,new A.ej(a2,i,k))}else{g=a2.Q==null
if(g){a6=a2.d
o=r.a(r.a(p.document).createElement("p"))
o.textContent="Path not defined for this scenario."
a6.append(o)}}break
case"Wall Following":f=j.$1$1(k,t.X)
g=f!=null
if(g){a2.v(a2.d,"Desired Distance",f.b,1,50,1,new A.ek(i,k))
a2.v(a2.d,"Feeler Length",f.c,10,150,1,new A.el(i,k))
a2.v(a2.d,"Wall Force",f.d,500,5000,10,new A.em(i,k))}break
case"Containment":f=j.$1$1(k,t.G)
g=f!=null
if(g){a2.v(a2.d,a3,f.b,5,100,1,new A.en(i,k))
a2.v(a2.d,"Force Increase",f.d,0.1,2,0.1,new A.eo(i,k))}break
case"Separation":case"Flocking":if(q.length!==0){c=j.$1$1(B.a.gY(q),t.o)
g=c!=null
if(g)a2.v(a2.d,"Separation Radius",c.b,5,100,1,new A.eq(a2,h))}else g=!1
break
case"Cohesion":if(q.length!==0){c=j.$1$1(B.a.gY(q),t.Z)
g=c!=null
if(g)a2.v(a2.d,a4,c.b,20,300,5,new A.er(a2,h))}else g=!1
break
case"Alignment":if(q.length!==0){c=j.$1$1(B.a.gY(q),t.r)
g=c!=null
if(g)a2.v(a2.d,a5,c.b,20,300,5,new A.es(a2,h))}else g=!1
break
case"Leader Following":if(q.length>1){b=j.$1$1(q[1],t.x)
g=b!=null
if(g){a2.v(a2.d,"Leader Behind Dist",b.c,10,150,1,new A.et(a2,i))
a2.v(a2.d,"Leader Sight Dist",b.d,5,100,1,new A.eu(a2,i))
a2.v(a2.d,"Leader Sight Radius",b.e,1,50,1,new A.ev(a2,i))}}else{a6=a2.d
o=r.a(r.a(p.document).createElement("p"))
o.textContent="Requires at least one follower."
a6.append(o)}break
default:g=!1}if(a2.cy==="Flocking")if(q.length!==0){a=B.a.gY(q)
a0=j.$1$1(a,t.Z)
e=!0
if(a0!=null){a2.d.append(r.a(r.a(p.document).createElement("hr")))
a2.v(a2.d,a4,a0.b,20,300,5,new A.ew(a2,h))
g=e}a1=j.$1$1(a,t.r)
if(a1!=null){a2.d.append(r.a(r.a(p.document).createElement("hr")))
a2.v(a2.d,a5,a1.b,20,300,5,new A.ex(a2,h))
g=e}}if(!g){a6=a2.d
a2=r.a(r.a(p.document).createElement("p"))
a2.textContent="No specific parameters for this behavior yet."
a6.append(a2)}},
bD(a,b,c,d,e,f,g,h){var s,r,q,p,o,n
t.gq.a(g)
s=self
r=t.m
q=r.a(r.a(s.document).createElement("div"))
r.a(q.classList).add("slider-container")
if(h!=null)q.id=h
p=r.a(r.a(s.document).createElement("label"))
p.textContent=b+": "
o=r.a(r.a(s.document).createElement("span"))
o.textContent=B.c.bo(c,f>=1?0:1)
r.a(o.classList).add("value-display")
n=r.a(r.a(s.document).createElement("input"))
n.type="range"
n.min=B.c.n(d)
n.max=B.c.n(e)
n.step=B.c.n(f)
n.value=B.c.n(c)
s=t.a
A.aA(n,"input",s.i("~(1)?").a(new A.dJ(n,o,f,g)),!1,s.c)
p.append(o)
q.append(p)
q.append(n)
a.append(q)},
v(a,b,c,d,e,f,g){return this.bD(a,b,c,d,e,f,g,null)},
aJ(){var s,r=t.z,q=r.a(t.m.a(self.document).querySelector("#followerSeparationSlider"))
if(q==null)return null
s=r.a(q.querySelector('input[type="range"]'))
if(s!=null){r=A.aD(s.value)
return A.ho(r)}return null},
c4(){var s,r,q,p,o,n,m=this,l=m.cx
l.X(0)
s=m.y
r=s.length
if(r<=1){if(r===1){r=m.ax
r=r!=null&&B.a.aa(s,r)}else r=!1
r=!r}else r=!1
if(r)return
for(r=s.length,q=0;q<s.length;s.length===r||(0,A.l)(s),++q){p=s[q]
o=p.e
n=p.f
l.l(0,p,new A.bU([p.r,n,o,p.w]))}l=m.w
l===$&&A.f()
l=A.fN(l.checked)
if(l)m.b0()},
b0(){var s,r,q,p,o,n,m,l,k=this.w
k===$&&A.f()
s=A.fN(k.checked)
for(k=this.y,r=k.length,q=this.cx,p=0;p<k.length;k.length===r||(0,A.l)(k),++p){o=k[p]
n=q.j(0,o)
if(n==null)continue
m=n.a
if(s){l=1+(B.d.K()*0.4-0.2)
o.e=B.c.a9(m[2]*l,10,1000)
o.f=B.c.a9(m[1]*l,10,1000)
o.r=B.c.a9(m[0]*l,0.1,20)
o.w=B.c.a9(m[3]*l,1,100)}else{o.e=m[2]
o.f=m[1]
o.r=m[0]
o.w=m[3]}}},
c2(){A.P(t.m.a(self.window).requestAnimationFrame(A.fc(new A.dQ(this))))},
b9(a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=this,a1=a0.db,a2=a1===0||a3<=a1?0.016:(a3-a1)/1000
a0.db=a3
a1=a0.as
if(a1!=null){a1.c.X(0)
a1.d.X(0)}if(a0.as!=null)for(a1=a0.y,s=a1.length,r=0;r<a1.length;a1.length===s||(0,A.l)(a1),++r){q=a1[r]
a0.as.h(0,q)}for(a1=a0.y,s=a1.length,r=0;r<a1.length;a1.length===s||(0,A.l)(a1),++r){q=a1[r]
p=a0.as
if(p!=null)p.co(q)
p=q.x
p===$&&A.f()
o=p.ca()
p=p.a
n=p.r
if(n>0.0001){m=new Float64Array(2)
l=new A.a(m)
k=o.a
m[1]=k[1]
m[0]=k[0]
l.A(1/n)}else l=new A.a(new Float64Array(2))
n=p.d
m=new Float64Array(2)
j=new A.a(m)
k=l.a
m[1]=k[1]
m[0]=k[0]
j.A(a2)
n.h(0,j)
n=p.d.gt()
m=p.e
if(n>m*m){p.d.N()
p.d.A(p.e)}n=p.c
p=p.d
m=new Float64Array(2)
j=new A.a(m)
k=p.a
m[1]=k[1]
m[0]=k[0]
j.A(a2)
n.h(0,j)}s=a0.b
s===$&&A.f()
s.clearRect(0,0,800,600)
a0.b.fillStyle="#f0f0f0"
a0.b.fillRect(0,0,800,600)
if(a0.ay!=null){a0.b.strokeStyle="lightgrey"
a0.b.lineWidth=1
s=a0.b
p=a0.ay
n=p.a.a
m=n[0]
n=n[1]
p=p.b.a
s.strokeRect(m,n,p[0]-m,p[1]-n)}s=a0.ch
if(s.length!==0){a0.b.strokeStyle="black"
a0.b.lineWidth=3
a0.b.beginPath()
for(p=s.length,r=0;r<s.length;s.length===p||(0,A.l)(s),++r){i=s[r]
n=i.a.a
a0.b.moveTo(n[0],n[1])
n=i.b.a
a0.b.lineTo(n[0],n[1])}a0.b.stroke()}if(a0.CW!=null&&a0.cy==="Flow Field Following"){a0.b.strokeStyle="rgba(0, 0, 200, 0.2)"
a0.b.lineWidth=1
s=a0.CW
h=s.b
for(g=0;g<s.d*s.b;++g,s=p)for(s=(g+0.5)*h,f=0;p=a0.CW,f<p.c*p.b;++f){n=new Float64Array(2)
n[0]=(f+0.5)*h
n[1]=s
e=p.bp(f,g)
if(e!=null){a0.b.beginPath()
a0.b.moveTo(n[0],n[1])
p=a0.b
m=n[0]
j=e.a
p.lineTo(m+j[0]*h*0.4,n[1]+j[1]*h*0.4)
a0.b.stroke()}}}if(a0.Q!=null){a0.b.strokeStyle="purple"
a0.b.lineWidth=1
a0.b.beginPath()
s=a0.Q.a
if(s.length!==0){a0.b.moveTo(B.a.gY(s).a[0],B.a.gY(a0.Q.a).a[1])
for(d=1;s=a0.Q.a,d<s.length;++d){p=a0.b
s=s[d].a
p.lineTo(s[0],s[1])}a0.b.stroke()}}for(s=a0.z,p=s.length,r=0;r<s.length;s.length===p||(0,A.l)(s),++r){c=s[r]
a0.b.beginPath()
n=a0.b
m=c.a.a
n.arc.apply(n,[m[0],m[1],c.b,0,6.283185307179586])
a0.b.fillStyle="grey"
a0.b.fill()
a0.b.strokeStyle="darkgrey"
a0.b.stroke()}if(a0.at!=null&&B.a.aa(A.d(["Seek","Flee","Arrival","Obstacle Avoidance"],t.U),a0.cy)){a0.b.beginPath()
s=a0.b
p=a0.at.a
A.k7(s,"arc",[p[0],p[1],5,0,6.283185307179586],t.H)
a0.b.fillStyle="lime"
a0.b.fill()
a0.b.strokeStyle="darkgreen"
a0.b.stroke()}for(s=a1.length,r=0;r<a1.length;a1.length===s||(0,A.l)(a1),++r){q=a1[r]
p=q.a
p.beginPath()
n=q.c.a
p.arc.apply(p,[n[0],n[1],q.w,0,6.283185307179586])
p.fillStyle=q.b
p.fill()
p.strokeStyle="black"
p.lineWidth=1
p.stroke()
if(q.d.gt()>0.01){p.beginPath()
n=q.c.a
p.moveTo(n[0],n[1])
n=q.d
m=new Float64Array(2)
k=n.a
m[1]=k[1]
m[0]=k[0]
new A.a(m).N()
n=q.c.a
j=n[0]
b=m[0]
a=q.w
p.lineTo(j+b*a*1.5,n[1]+m[1]*a*1.5)
p.strokeStyle="red"
p.lineWidth=2
p.stroke()}}A.P(t.m.a(self.window).requestAnimationFrame(A.fc(new A.dK(a0))))}}
A.dL.prototype={
$1(a){var s=this.a,r=s.c
r===$&&A.f()
r=A.aD(r.value)
s.bh(r)},
$S:3}
A.dM.prototype={
$1(a){var s=this.a
s.bi(s.cy,!0)
s.bk()},
$S:3}
A.dN.prototype={
$1(a){var s,r,q,p,o=this.a
if(B.a.aa(A.d(["Seek","Flee","Arrival","Obstacle Avoidance"],t.U),o.cy)){s=A.aM(a.offsetX)
r=A.aM(a.offsetY)
q=new A.a(new Float64Array(2))
q.m(s,r)
o.at=q
s=o.y
if(s.length!==0){p=B.a.gY(s)
s=t.R
r=p.a5(s)
if(r!=null){q=o.at
q.toString
r.a=q}r=p.a5(t.eH)
if(r!=null){q=o.at
q.toString
r.a=q}r=p.a5(t.J)
if(r!=null){q=o.at
q.toString
r.a=q}s=p.a5(s)
if(s!=null){o=o.at
o.toString
s.a=o}}}},
$S:3}
A.dO.prototype={
$1(a){var s=this.a.e
s===$&&A.f()
A.fN(t.m.a(s.classList).toggle("visible"))},
$S:3}
A.dP.prototype={
$1(a){this.a.b0()},
$S:3}
A.ec.prototype={
$1(a){var s,r,q,p
for(s=this.a,r=s.y,q=r.length,p=0;p<q;++p)r[p].e=a
q=s.ax
if(q!=null&&!B.a.aa(r,q))s.ax.e=a},
$S:0}
A.ed.prototype={
$1(a){var s,r,q,p
for(s=this.a,r=s.y,q=r.length,p=0;p<q;++p)r[p].f=a
q=s.ax
if(q!=null&&!B.a.aa(r,q))s.ax.f=a},
$S:0}
A.ee.prototype={
$1(a){var s,r,q,p
for(s=this.a,r=s.y,q=r.length,p=0;p<q;++p)r[p].r=a
q=s.ax
if(q!=null&&!B.a.aa(r,q))s.ax.r=a},
$S:0}
A.ep.prototype={
$1(a){var s,r,q,p
for(s=this.a,r=s.y,q=r.length,p=0;p<q;++p)r[p].w=a
q=s.ax
if(q!=null&&!B.a.aa(r,q))s.ax.w=a},
$S:0}
A.eF.prototype={
$1$1(a,b){var s
A.c4(b,t.s,"T","call")
s=a.a5(b)
return s},
$1(a){return this.$1$1(a,t.s)},
$S:30}
A.eG.prototype={
$1$2(a,b,c){var s,r,q,p,o,n=t.s
A.c4(c,n,"T","call")
c.i("0(0)").a(b)
s=a.a5(c)
if(s!=null){A.c4(c,n,"T","getBehaviorWeight")
r=a.y
q=r.j(0,A.ab(c))
p=q==null?null:q.b
if(p==null)p=1
A.c4(c,n,"T","removeBehavior")
o=r.a4(0,A.ab(c))
if(o!=null){n=a.x
n===$&&A.f()
n.a4(0,o.a)}a.ak(b.$1(s),p)}},
$2(a,b){return this.$1$2(a,b,t.s)},
$S:31}
A.eH.prototype={
$1$1(a,b){var s,r,q,p,o,n
A.c4(b,t.s,"T","call")
b.i("0(0)").a(a)
for(s=this.a,r=s.y,q=r.length,p=this.b,o=0;o<r.length;r.length===q||(0,A.l)(r),++o){n=r[o]
if(s.cy==="Leader Following"&&n===B.a.gY(r))continue
p.$1$2(n,a,b)}},
$1(a){return this.$1$1(a,t.s)},
$S:32}
A.ey.prototype={
$1(a){return this.a.b=a},
$S:5}
A.ez.prototype={
$1(a){this.a.$1$2(this.b,new A.e4(a),t.p)},
$S:0}
A.e4.prototype={
$1(a){t.p.a(a)
return A.an(a.c,this.a,a.b)},
$S:6}
A.eA.prototype={
$1(a){this.a.$1$2(this.b,new A.e2(a),t.p)},
$S:0}
A.e2.prototype={
$1(a){t.p.a(a)
return A.an(a.c,a.a,this.a)},
$S:6}
A.eB.prototype={
$1(a){this.a.$1$2(this.b,new A.e1(a),t.p)},
$S:0}
A.e1.prototype={
$1(a){t.p.a(a)
return A.an(this.a,a.a,a.b)},
$S:6}
A.eC.prototype={
$1(a){this.a.$1$2(this.b,new A.e0(a),t.G)},
$S:0}
A.e0.prototype={
$1(a){t.G.a(a)
return new A.r(a.d,a.a,this.a)},
$S:4}
A.eD.prototype={
$1(a){this.a.$1$2(this.b,new A.e_(a),t.G)},
$S:0}
A.e_.prototype={
$1(a){t.G.a(a)
return new A.r(this.a,a.a,a.b)},
$S:4}
A.eE.prototype={
$1(a){this.a.b.saS(a)
return a},
$S:5}
A.ef.prototype={
$1(a){this.a.b.saT(a)
return a},
$S:5}
A.eg.prototype={
$1(a){this.a.$1$2(this.b,new A.dZ(a),t.f)},
$S:0}
A.dZ.prototype={
$1(a){t.f.a(a)
return A.fF(a.c,this.a,a.a)},
$S:16}
A.eh.prototype={
$1(a){this.a.$1$2(this.b,new A.dY(a),t.f)},
$S:0}
A.dY.prototype={
$1(a){t.f.a(a)
return A.fF(this.a,a.b,a.a)},
$S:16}
A.ei.prototype={
$1(a){var s=this.a
s.Q=A.hm(!1,s.Q.a,a)
this.b.$1$2(this.c,new A.dX(s),t.j)},
$S:0}
A.dX.prototype={
$1(a){var s
t.j.a(a)
s=this.a.Q
s.toString
return new A.a0(s,a.b,new A.a(new Float64Array(2)))},
$S:17}
A.ej.prototype={
$1(a){this.b.$1$2(this.c,new A.dW(this.a,a),t.j)},
$S:0}
A.dW.prototype={
$1(a){var s
t.j.a(a)
s=this.a.Q
s.toString
return new A.a0(s,this.b,new A.a(new Float64Array(2)))},
$S:17}
A.ek.prototype={
$1(a){this.a.$1$2(this.b,new A.dV(a),t.X)},
$S:0}
A.dV.prototype={
$1(a){t.X.a(a)
return A.eR(this.a,a.c,a.d,a.a)},
$S:7}
A.el.prototype={
$1(a){this.a.$1$2(this.b,new A.dU(a),t.X)},
$S:0}
A.dU.prototype={
$1(a){t.X.a(a)
return A.eR(a.b,this.a,a.d,a.a)},
$S:7}
A.em.prototype={
$1(a){this.a.$1$2(this.b,new A.eb(a),t.X)},
$S:0}
A.eb.prototype={
$1(a){t.X.a(a)
return A.eR(a.b,a.c,this.a,a.a)},
$S:7}
A.en.prototype={
$1(a){this.a.$1$2(this.b,new A.ea(a),t.G)},
$S:0}
A.ea.prototype={
$1(a){t.G.a(a)
return new A.r(a.d,a.a,this.a)},
$S:4}
A.eo.prototype={
$1(a){this.a.$1$2(this.b,new A.e9(a),t.G)},
$S:0}
A.e9.prototype={
$1(a){t.G.a(a)
return new A.r(this.a,a.a,a.b)},
$S:4}
A.eq.prototype={
$1(a){this.b.$1$1(new A.e8(this.a,a),t.o)},
$S:0}
A.e8.prototype={
$1(a){var s
t.o.a(a)
s=this.a.as
s.toString
return new A.a1(s,this.b)},
$S:34}
A.er.prototype={
$1(a){this.b.$1$1(new A.e7(this.a,a),t.Z)},
$S:0}
A.e7.prototype={
$1(a){var s
t.Z.a(a)
s=this.a.as
s.toString
return new A.a_(s,this.b)},
$S:18}
A.es.prototype={
$1(a){this.b.$1$1(new A.e6(this.a,a),t.r)},
$S:0}
A.e6.prototype={
$1(a){var s
t.r.a(a)
s=this.a.as
s.toString
return new A.Z(s,this.b)},
$S:19}
A.et.prototype={
$1(a){var s,r,q,p,o=this.a,n=o.aJ()
for(o=o.y,o=A.eN(o,1,null,A.F(o).c),s=o.$ti,o=new A.R(o,o.gq(0),s.i("R<v.E>")),r=this.b,q=t.x,s=s.i("v.E");o.C();){p=o.d
if(p==null)p=s.a(p)
r.$1$2(p,new A.e5(a,n),q)}},
$S:0}
A.e5.prototype={
$1(a){t.x.a(a)
return A.dq(this.b,a.a,this.a,a.d,a.e,a.b)},
$S:8}
A.eu.prototype={
$1(a){var s,r,q,p,o=this.a,n=o.aJ()
for(o=o.y,o=A.eN(o,1,null,A.F(o).c),s=o.$ti,o=new A.R(o,o.gq(0),s.i("R<v.E>")),r=this.b,q=t.x,s=s.i("v.E");o.C();){p=o.d
if(p==null)p=s.a(p)
r.$1$2(p,new A.e3(a,n),q)}},
$S:0}
A.e3.prototype={
$1(a){t.x.a(a)
return A.dq(this.b,a.a,a.c,this.a,a.e,a.b)},
$S:8}
A.ev.prototype={
$1(a){var s,r,q,p,o=this.a,n=o.aJ()
for(o=o.y,o=A.eN(o,1,null,A.F(o).c),s=o.$ti,o=new A.R(o,o.gq(0),s.i("R<v.E>")),r=this.b,q=t.x,s=s.i("v.E");o.C();){p=o.d
if(p==null)p=s.a(p)
r.$1$2(p,new A.dT(a,n),q)}},
$S:0}
A.dT.prototype={
$1(a){t.x.a(a)
return A.dq(this.b,a.a,a.c,a.d,this.a,a.b)},
$S:8}
A.ew.prototype={
$1(a){this.b.$1$1(new A.dS(this.a,a),t.Z)},
$S:0}
A.dS.prototype={
$1(a){var s
t.Z.a(a)
s=this.a.as
s.toString
return new A.a_(s,this.b)},
$S:18}
A.ex.prototype={
$1(a){this.b.$1$1(new A.dR(this.a,a),t.r)},
$S:0}
A.dR.prototype={
$1(a){var s
t.r.a(a)
s=this.a.as
s.toString
return new A.Z(s,this.b)},
$S:19}
A.dJ.prototype={
$1(a){var s,r=this,q=A.aD(r.a.value),p=A.kd(q)
q=r.c>=1?0:1
r.b.textContent=J.iu(p,q)
try{r.d.$1(p)}catch(s){A.aF(s)}},
$S:3}
A.dQ.prototype={
$1(a){this.a.b9(A.aM(a))},
$S:0}
A.dK.prototype={
$1(a){this.a.b9(A.aM(a))},
$S:0}
A.fw.prototype={
$1(a){var s,r,q,p,o,n,m
A.aM(a)
try{s=new A.dI(A.d([],t.dT),A.d([],t.d7),A.d([],t.aB),A.H(t.f8,t.er))
r=self
q=t.m
p=t.z
o=p.a(q.a(r.document).querySelector("#steeringCanvas"))
o=q.a(o==null?q.a(o):o)
s.a=o
n=p.a(o.getContext("2d"))
s.b=q.a(n==null?q.a(n):n)
n=p.a(q.a(r.document).querySelector("#behaviorSelector"))
s.c=q.a(n==null?q.a(n):n)
n=p.a(q.a(r.document).querySelector("#parameterPanel"))
s.d=q.a(n==null?q.a(n):n)
n=p.a(q.a(r.document).querySelector("#controls"))
s.e=q.a(n==null?q.a(n):n)
n=p.a(q.a(r.document).querySelector("#resetButton"))
s.f=q.a(n==null?q.a(n):n)
n=p.a(q.a(r.document).querySelector("#paramsToggleButton"))
s.r=q.a(n==null?q.a(n):n)
n=p.a(q.a(r.document).querySelector("#randomizeParamsCheckbox"))
s.w=q.a(n==null?q.a(n):n)
r=p.a(q.a(r.document).querySelector("#agentRandomizationControl"))
s.x=q.a(r==null?q.a(r):r)
o.width=800
o.height=600
s.bY()
s.bh(s.cy)
s.c2()}catch(m){A.aF(m)
s=self
t.m.a(s.window).alert("Failed to initialize Steering Demo. Check console for errors.")}},
$S:0};(function aliases(){var s=J.ax.prototype
s.bw=s.n})();(function installTearOffs(){var s=hunkHelpers._static_0,r=hunkHelpers._static_1,q=hunkHelpers._static_2
s(A,"jS","iV",11)
r(A,"k4","j6",9)
r(A,"k5","j7",9)
r(A,"k6","j8",9)
s(A,"i1","jY",1)
s(A,"kv","kc",10)
s(A,"kt","k9",10)
s(A,"ku","ka",10)
q(A,"a3","iH",15)
q(A,"kj","iI",15)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.n,null)
q(A.n,[A.fB,J.ck,J.bd,A.o,A.dE,A.h,A.R,A.bv,A.bI,A.w,A.a2,A.bf,A.au,A.eP,A.dt,A.bW,A.aV,A.dr,A.bq,A.V,A.cQ,A.cV,A.f9,A.at,A.bK,A.X,A.cL,A.bE,A.c1,A.bN,A.aZ,A.cS,A.aL,A.u,A.bP,A.cg,A.cz,A.bD,A.eX,A.df,A.L,A.cU,A.eK,A.cG,A.cR,A.I,A.bk,A.q,A.de,A.aH,A.az,A.ah,A.dw,A.dx,A.dg,A.x,A.eI,A.D,A.dF,A.a,A.fz,A.cP,A.ay,A.cA,A.a7,A.dI])
q(J.ck,[J.cl,J.bm,J.bo,J.bn,J.bp,J.aS,J.aT])
q(J.bo,[J.ax,J.t,A.co,A.bz])
q(J.ax,[J.cB,J.b2,J.aw])
r(J.dm,J.t)
q(J.aS,[J.bl,J.cm])
q(A.o,[A.aU,A.aj,A.cn,A.cJ,A.cM,A.cE,A.be,A.cO,A.a6,A.bG,A.cI,A.b0,A.cd])
q(A.h,[A.bg,A.bu,A.bH])
q(A.bg,[A.v,A.br,A.bM])
q(A.v,[A.bF,A.bw,A.S,A.bs])
q(A.a2,[A.aC,A.b5])
q(A.aC,[A.j,A.G,A.B])
r(A.bU,A.b5)
r(A.av,A.bf)
q(A.au,[A.cb,A.cc,A.cH,A.fm,A.fo,A.eT,A.eS,A.f3,A.eL,A.f8,A.dy,A.di,A.eJ,A.eW,A.fj,A.fk,A.fs,A.ft,A.dL,A.dM,A.dN,A.dO,A.dP,A.ec,A.ed,A.ee,A.ep,A.eF,A.eG,A.eH,A.ey,A.ez,A.e4,A.eA,A.e2,A.eB,A.e1,A.eC,A.e0,A.eD,A.e_,A.eE,A.ef,A.eg,A.dZ,A.eh,A.dY,A.ei,A.dX,A.ej,A.dW,A.ek,A.dV,A.el,A.dU,A.em,A.eb,A.en,A.ea,A.eo,A.e9,A.eq,A.e8,A.er,A.e7,A.es,A.e6,A.et,A.e5,A.eu,A.e3,A.ev,A.dT,A.ew,A.dS,A.ex,A.dR,A.dJ,A.dQ,A.dK,A.fw])
q(A.cb,[A.dz,A.eU,A.eV,A.fa,A.eY,A.f_,A.eZ,A.f2,A.f1,A.f0,A.eM,A.fe,A.f7,A.dG,A.dH,A.fv,A.fu])
r(A.bB,A.aj)
q(A.cH,[A.cF,A.aR])
r(A.cK,A.be)
q(A.aV,[A.aJ,A.bL])
q(A.cc,[A.fn,A.f4,A.ds,A.d_,A.d1,A.d3,A.d4,A.d6,A.d7,A.da,A.db,A.dd,A.dp,A.dv,A.fg])
q(A.bz,[A.cp,A.aW])
q(A.aW,[A.bQ,A.bS])
r(A.bR,A.bQ)
r(A.bx,A.bR)
r(A.bT,A.bS)
r(A.by,A.bT)
q(A.bx,[A.cq,A.cr])
q(A.by,[A.cs,A.ct,A.cu,A.cv,A.cw,A.bA,A.cx])
r(A.bX,A.cO)
r(A.cT,A.c1)
r(A.bV,A.aZ)
r(A.bO,A.bV)
q(A.a6,[A.aX,A.cj])
q(A.q,[A.Z,A.aQ,A.a_,A.ce,A.bh,A.bi,A.ci,A.ad,A.af,A.bC,A.a0,A.cD,A.aK,A.a1,A.al,A.am])
q(A.dx,[A.c9,A.d0,A.dc,A.d2,A.d5,A.d8,A.d9,A.cf,A.dj,A.dn,A.du])
r(A.bJ,A.bE)
r(A.cN,A.bJ)
r(A.r,A.ce)
s(A.bQ,A.u)
s(A.bR,A.w)
s(A.bS,A.u)
s(A.bT,A.w)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{b:"int",i:"double",b9:"num",W:"String",aa:"bool",L:"Null",k:"List",n:"Object",ae:"Map"},mangledNames:{},types:["L(i)","~()","b(x,x)","~(y)","r(r)","i(i)","am(am)","al(al)","ad(ad)","~(~())","ay()","b()","k<bb>()","L()","L(@)","i(b,b)","af(af)","a0(a0)","a_(a_)","Z(Z)","@(@)","@(@,W)","L(n,b_)","~(n?,n?)","a(a)","x(b)","aa(D)","@(W)","~(b,b)","I<b>(x?)","0^?(a7?)<q>","~(a7,0^(0^))<q>","~(0^(0^))<q>","L(~())","a1(a1)","aa(x?)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{"2;":(a,b)=>c=>c instanceof A.j&&a.b(c.a)&&b.b(c.b),"2;behavior,weight":(a,b)=>c=>c instanceof A.G&&a.b(c.a)&&b.b(c.b),"2;description,interaction":(a,b)=>c=>c instanceof A.B&&a.b(c.a)&&b.b(c.b),"4;mass,maxForce,maxSpeed,radius":a=>b=>b instanceof A.bU&&A.ks(a,b.a)}}
A.jq(v.typeUniverse,JSON.parse('{"cB":"ax","b2":"ax","aw":"ax","cl":{"aa":[],"m":[]},"bm":{"m":[]},"bo":{"y":[]},"ax":{"y":[]},"t":{"k":["1"],"y":[],"h":["1"]},"dm":{"t":["1"],"k":["1"],"y":[],"h":["1"]},"bd":{"O":["1"]},"aS":{"i":[],"b9":[]},"bl":{"i":[],"b":[],"b9":[],"m":[]},"cm":{"i":[],"b9":[],"m":[]},"aT":{"W":[],"m":[]},"aU":{"o":[]},"bg":{"h":["1"]},"v":{"h":["1"]},"bF":{"v":["1"],"h":["1"],"v.E":"1","h.E":"1"},"R":{"O":["1"]},"bu":{"h":["2"],"h.E":"2"},"bv":{"O":["2"]},"bw":{"v":["2"],"h":["2"],"v.E":"2","h.E":"2"},"bH":{"h":["1"],"h.E":"1"},"bI":{"O":["1"]},"S":{"v":["1"],"h":["1"],"v.E":"1","h.E":"1"},"j":{"aC":[],"a2":[]},"G":{"aC":[],"a2":[]},"B":{"aC":[],"a2":[]},"bU":{"b5":[],"a2":[]},"bf":{"ae":["1","2"]},"av":{"bf":["1","2"],"ae":["1","2"]},"bB":{"aj":[],"o":[]},"cn":{"o":[]},"cJ":{"o":[]},"bW":{"b_":[]},"au":{"aI":[]},"cb":{"aI":[]},"cc":{"aI":[]},"cH":{"aI":[]},"cF":{"aI":[]},"aR":{"aI":[]},"cM":{"o":[]},"cE":{"o":[]},"cK":{"o":[]},"aJ":{"aV":["1","2"],"hh":["1","2"],"ae":["1","2"]},"br":{"h":["1"],"h.E":"1"},"bq":{"O":["1"]},"aC":{"a2":[]},"b5":{"a2":[]},"co":{"y":[],"m":[]},"bz":{"y":[]},"cp":{"y":[],"m":[]},"aW":{"Q":["1"],"y":[]},"bx":{"u":["i"],"k":["i"],"Q":["i"],"y":[],"h":["i"],"w":["i"]},"by":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"]},"cq":{"u":["i"],"k":["i"],"Q":["i"],"y":[],"h":["i"],"w":["i"],"m":[],"u.E":"i","w.E":"i"},"cr":{"fA":[],"u":["i"],"k":["i"],"Q":["i"],"y":[],"h":["i"],"w":["i"],"m":[],"u.E":"i","w.E":"i"},"cs":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"],"m":[],"u.E":"b","w.E":"b"},"ct":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"],"m":[],"u.E":"b","w.E":"b"},"cu":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"],"m":[],"u.E":"b","w.E":"b"},"cv":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"],"m":[],"u.E":"b","w.E":"b"},"cw":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"],"m":[],"u.E":"b","w.E":"b"},"bA":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"],"m":[],"u.E":"b","w.E":"b"},"cx":{"u":["b"],"k":["b"],"Q":["b"],"y":[],"h":["b"],"w":["b"],"m":[],"u.E":"b","w.E":"b"},"cV":{"hx":[]},"cO":{"o":[]},"bX":{"aj":[],"o":[]},"at":{"o":[]},"X":{"bj":["1"]},"c1":{"hA":[]},"cT":{"c1":[],"hA":[]},"bL":{"aV":["1","2"],"iG":["1","2"],"ae":["1","2"]},"bM":{"h":["1"],"h.E":"1"},"bN":{"O":["1"]},"bO":{"aZ":["1"],"h":["1"]},"aL":{"O":["1"]},"aV":{"ae":["1","2"]},"bs":{"v":["1"],"h":["1"],"v.E":"1","h.E":"1"},"bP":{"O":["1"]},"aZ":{"h":["1"]},"bV":{"aZ":["1"],"h":["1"]},"i":{"b9":[]},"b":{"b9":[]},"k":{"h":["1"]},"be":{"o":[]},"aj":{"o":[]},"a6":{"o":[]},"aX":{"o":[]},"cj":{"o":[]},"bG":{"o":[]},"cI":{"o":[]},"b0":{"o":[]},"cd":{"o":[]},"cz":{"o":[]},"bD":{"o":[]},"cU":{"b_":[]},"cR":{"iY":[]},"Z":{"q":[]},"aQ":{"q":[]},"a_":{"q":[]},"ce":{"q":[]},"bh":{"q":[]},"bi":{"q":[]},"ci":{"q":[]},"ad":{"q":[]},"af":{"q":[]},"bC":{"q":[]},"a0":{"q":[]},"cD":{"q":[]},"aK":{"q":[]},"a1":{"q":[]},"al":{"q":[]},"am":{"q":[]},"aH":{"cy":[]},"az":{"cy":[]},"ah":{"cy":[]},"bJ":{"bE":["1"]},"cN":{"bJ":["1"],"bE":["1"]},"a7":{"bb":[]},"r":{"q":[]},"iL":{"k":["b"],"h":["b"]},"j3":{"k":["b"],"h":["b"]},"j2":{"k":["b"],"h":["b"]},"iJ":{"k":["b"],"h":["b"]},"j0":{"k":["b"],"h":["b"]},"iK":{"k":["b"],"h":["b"]},"j1":{"k":["b"],"h":["b"]},"iE":{"k":["i"],"h":["i"]},"fA":{"k":["i"],"h":["i"]}}'))
A.jp(v.typeUniverse,JSON.parse('{"bg":1,"aW":1,"bV":1}'))
var u={g:"Click on the canvas to set the target position (green circle).",c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type"}
var t=(function rtii(){var s=A.c5
return{E:s("bb"),r:s("Z"),J:s("aQ"),n:s("at"),Z:s("a_"),I:s("av<W,b>"),G:s("r"),f8:s("a7"),Q:s("o"),eH:s("bi"),Y:s("aI"),b9:s("bj<@>"),t:s("bk<x>"),hf:s("h<@>"),g:s("t<bb>"),d7:s("t<aH>"),dT:s("t<a7>"),_:s("t<x>"),L:s("t<n>"),ce:s("t<+(b,b)>"),U:s("t<W>"),e:s("t<a>"),aB:s("t<az>"),cT:s("t<D>"),u:s("t<@>"),eI:s("t<x?>"),T:s("bm"),m:s("y"),O:s("aw"),aU:s("Q<@>"),x:s("ad"),cH:s("k<bb>"),w:s("k<k<x>>"),b:s("k<x>"),aH:s("k<@>"),q:s("ae<x,x>"),g6:s("ae<W,b>"),A:s("x"),P:s("L"),K:s("n"),f:s("af"),gu:s("bC"),j:s("a0"),D:s("I<b>"),gT:s("kG"),bQ:s("+()"),h5:s("+behavior,weight(q,i)"),dL:s("+(b,b)"),er:s("+mass,maxForce,maxSpeed,radius(i,i,i,i)"),V:s("S<x>"),R:s("aK"),o:s("a1"),l:s("b_"),s:s("q"),N:s("W"),dm:s("m"),dd:s("hx"),eK:s("aj"),ak:s("b2"),h:s("a"),X:s("al"),p:s("am"),fO:s("D"),a:s("cN<y>"),d:s("X<@>"),fJ:s("X<b>"),y:s("aa"),al:s("aa(n)"),i:s("i"),B:s("@"),he:s("@()"),v:s("@(n)"),C:s("@(n,b_)"),gq:s("@(i)"),S:s("b"),W:s("0&*"),c:s("n*"),bG:s("bj<L>?"),z:s("y?"),k:s("x?"),cK:s("n?"),F:s("bK<@,@>?"),br:s("cS?"),g5:s("~()?"),di:s("b9"),H:s("~"),M:s("~()")}})();(function constants(){var s=hunkHelpers.makeConstList
B.w=J.ck.prototype
B.a=J.t.prototype
B.b=J.bl.prototype
B.c=J.aS.prototype
B.i=J.aT.prototype
B.x=J.aw.prototype
B.y=J.bo.prototype
B.m=J.cB.prototype
B.j=J.b2.prototype
B.k=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.n=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.t=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.o=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.r=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.q=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.p=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.l=function(hooks) { return hooks; }

B.u=new A.cz()
B.f=new A.dE()
B.d=new A.cR()
B.e=new A.cT()
B.v=new A.cU()
B.h={dx:0,dy:1}
B.D=new A.av(B.h,[0,-2],t.I)
B.B=new A.av(B.h,[2,0],t.I)
B.C=new A.av(B.h,[0,2],t.I)
B.A=new A.av(B.h,[-2,0],t.I)
B.z=A.d(s([B.D,B.B,B.C,B.A]),A.c5("t<ae<W,b>>"))
B.E=new A.B("Agents steer to avoid crowding local flockmates.","No user interaction.")
B.F=new A.j(0,1)
B.G=new A.j(0,-1)
B.H=new A.j(1,0)
B.I=new A.B("Agent (blue) predicts the future position of a pursuer (red) and moves away.","No user interaction.")
B.J=new A.B("Agents steer towards the average heading of local flockmates.","No user interaction.")
B.K=new A.B("Agent moves away from a target position.","Click on the canvas to set the flee target position (green circle).")
B.L=new A.B("Agent follows vectors defined in a flow field. (Demo field points towards the bottom right).","No user interaction.")
B.M=new A.B("Agents (teal) follow a leader agent (orange), maintaining position and avoiding crowding.","No user interaction.")
B.N=new A.B("Agent moves towards a target position.",u.g)
B.O=new A.B("Agents steer to move toward the average position of local flockmates.","No user interaction.")
B.P=new A.B("Agent moves randomly using a projected circle and target displacement.","No user interaction.")
B.Q=new A.B("Agent attempts to follow along walls (black lines) maintaining a set distance.","No user interaction.")
B.R=new A.B("Agent (purple) maintains a specific offset position relative to a leader agent (green).","No user interaction.")
B.S=new A.B("Agent follows a predefined path (purple line).","No user interaction.")
B.T=new A.B("Combines Separation, Cohesion, and Alignment to simulate flocking behavior.","No user interaction.")
B.U=new A.B("Placeholder demo showing multiple agents wandering. Separation is used to prevent overlap, but true Unaligned Collision Avoidance (like RVO) is not implemented.","No user interaction.")
B.V=new A.j(-1,0)
B.W=new A.B("Agent attempts to steer around obstacles (grey circles) while moving towards a target.","Click on the canvas to set the seek target position (green circle).")
B.X=new A.B("Agent is kept within defined boundaries (light grey rectangle). Force increases further outside.","No user interaction.")
B.Y=new A.B("Agent (red) predicts the future position of a target agent (green) and intercepts it.","No user interaction.")
B.Z=new A.B("Agent moves towards a target position, slowing down as it approaches.",u.g)
B.a_=A.a5("kD")
B.a0=A.a5("kE")
B.a1=A.a5("iE")
B.a2=A.a5("fA")
B.a3=A.a5("iJ")
B.a4=A.a5("iK")
B.a5=A.a5("iL")
B.a6=A.a5("n")
B.a7=A.a5("j0")
B.a8=A.a5("j1")
B.a9=A.a5("j2")
B.aa=A.a5("j3")})();(function staticFields(){$.f5=null
$.T=A.d([],t.L)
$.hn=null
$.dB=0
$.dC=A.jS()
$.h7=null
$.h6=null
$.i5=null
$.i_=null
$.ia=null
$.fi=null
$.fp=null
$.fW=null
$.f6=A.d([],A.c5("t<k<n>?>"))
$.b6=null
$.c2=null
$.c3=null
$.fQ=!1
$.E=B.e
$.ib=A.H(t.N,A.c5("ay"))
$.fr=A.H(t.N,A.c5("cA?"))})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"kF","h_",()=>A.kh("_$dart_dartClosure"))
s($,"kI","id",()=>A.ak(A.eQ({
toString:function(){return"$receiver$"}})))
s($,"kJ","ie",()=>A.ak(A.eQ({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"kK","ig",()=>A.ak(A.eQ(null)))
s($,"kL","ih",()=>A.ak(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kO","ik",()=>A.ak(A.eQ(void 0)))
s($,"kP","il",()=>A.ak(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kN","ij",()=>A.ak(A.hy(null)))
s($,"kM","ii",()=>A.ak(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"kR","io",()=>A.ak(A.hy(void 0)))
s($,"kQ","im",()=>A.ak(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"kS","h1",()=>A.j5())
s($,"l0","cZ",()=>A.i8(B.a6))
s($,"kH","h0",()=>{A.iX()
return $.dB})
s($,"l1","ip",()=>A.iP(["Seek",B.N,"Flee",B.K,"Arrival",B.Z,"Wander",B.P,"Pursuit",B.Y,"Evade",B.I,"Offset Pursuit",B.R,"Obstacle Avoidance",B.W,"Path Following",B.S,"Wall Following",B.Q,"Containment",B.X,"Flow Field Following",B.L,"Unaligned Collision Avoidance",B.U,"Separation",B.E,"Cohesion",B.O,"Alignment",B.J,"Flocking",B.T,"Leader Following",B.M],t.N,A.c5("+description,interaction(W,W)")))})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.co,ArrayBufferView:A.bz,DataView:A.cp,Float32Array:A.cq,Float64Array:A.cr,Int16Array:A.cs,Int32Array:A.ct,Int8Array:A.cu,Uint16Array:A.cv,Uint32Array:A.cw,Uint8ClampedArray:A.bA,CanvasPixelArray:A.bA,Uint8Array:A.cx})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.aW.$nativeSuperclassTag="ArrayBufferView"
A.bQ.$nativeSuperclassTag="ArrayBufferView"
A.bR.$nativeSuperclassTag="ArrayBufferView"
A.bx.$nativeSuperclassTag="ArrayBufferView"
A.bS.$nativeSuperclassTag="ArrayBufferView"
A.bT.$nativeSuperclassTag="ArrayBufferView"
A.by.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$7=function(a,b,c,d,e,f,g){return this(a,b,c,d,e,f,g)}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$2=function(a,b){return this(a,b)}
Function.prototype.$5=function(a,b,c,d,e){return this(a,b,c,d,e)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=A.kq
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()
//# sourceMappingURL=main.dart.js.map
