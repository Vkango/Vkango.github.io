#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#show: project.with(
  title: "从泰勒展开式角度看拉格朗日型余项公式",
  authors: (
    (
      name: "Vkango",
      email: "hivkan@outlook.com",
    ),
  ),
)

#set par(justify: true)
#set heading(numbering: "1.")

#set text(font: ("New Computer Modern", "Source Han Serif"))
#show math.equation: set text(font: ("New Computer Modern Math", "Source Han Serif"))

#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)

#set heading(numbering: "1.1.")
#let theorem = thmbox(
  "theorem",
  "Theorem",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let corollary = thmplain(
  "corollary",
  "Corollary",
  titlefmt: strong,
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let property = thmplain(
  "property",
  "Property",
  titlefmt: strong,
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let definition = thmbox(
  "definition",
  "Definition",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let problem = thmbox(
  "problem",
  "Problem",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let thinking = thmbox(
  "thinking",
  "Thinking",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)

近期在学习插值函数, 刚开始学待定系数法, 上来就给了一个余项定理, 也即:

$
  R_n (x)=f(x)-L_n (x)=(f^((n+1))(xi))/((n+1)!)omega_(n+1)(x),xi in (a,b)
$

其中$omega_(n+1)(x)=Pi_(j=0)^n (x-x_j)$.

嗯, 就挺秃然的. 下面开始介绍.

#v(50pt)

以待定系数法为研究对象, 设一个$n$次多项式$ P_n (x)=a_0+a_1x+...+a_n x^n $然后要求它满足$P_n (x)=f(x_j)(j=0,1,...,n)$

于是得到一个线性方程组, 解出这些系数. 很自然, 因为我们确实在找一个多项式, 去拟合函数在若干点上的值.

接下来介绍余项公式$R_n (x)$.

= 引入

我们关心的问题是, 这个多项式在*别的点*上和$f(x)$相差多少? 在这里引入余项公式$ R_n (x)=f(x)-P_n (x) $

= 余项公式的基本性质

#property[
  $ R_n (x_j)=f(x_j)-P_n (x_j)=0quad forall j =0,1,...,n. $]

换个角度看插值问题, 可以理解为:

找到一个$n$次多项式$P_n$, 使得误差$R_n=f-P_n$在$x_0,...,x_n$这$n+1$个点全部为0.

= 问题

要求$R_n$在这$n+1$个点全部为0, 一定说明$R_n$含有:$ Pi_(j=0)^n (x-x_j) $

这句话对*多项式*来说是正确的. 因为多项式有因式定理: $ Q(x_j)=0=>x-x_j"是 "Q" 的因子" $

但是这里的$R_n (x)=f(x)-P_n (x)$一般不是多项式, 除非$f$本身就是多项式, 否则无法直接使用*多项式的因式定理*.

#thinking[从直觉上来看, 既然误差在$x_0,...,x_n$都为0, 那么一个最自然的零点模板就是$omega_(n+1) (x)=Pi_(j=0)^n (x-x_j)$.

  所以认为误差的结构会与$omega_(n+1)$相关.

  但是这只能是启发.]

= 思考

既然不能确保使用$R_n (x)$是多项式函数, 那我们能否直接把$f(x)$用泰勒展开式, 这样$f(x)$和$P_n (x)$就都是多项式函数了?

== $f(x)$在$a$处的展开

设$f$至少有$n+1$阶函数. 把它在点$a$处展开到$n$阶:$ f(x)=T_n (x)+rho_n (x) $

其中$ T_n (x)=sum_(k=0)^n (f^((k))(a))/k! (x-a)^k $

也即$n$次泰勒多项式, 而$rho_n (x)$是余项.


== 余项公式

现在的插值误差就是$ R_n (x)=f(x)-P_n (x)=(T_n (x)-P_n (x))+rho_n (x) $

从这里看, 我们将函数拆分成了多项式函数 + 高阶剩余函数.

== 验证

定义$ Q_n (x)=T_n (x)-P_n (x) $

目标是判断$Q_n (x)$中是否包含固定的$omega_(n+1)(x)$项. 也即, 当$Q_n (x_j)$是否为0.

从形式上看, 因为$T_n$和$P_n$都是*次数不超过$n$的多项式*, 所以$Q_n$也是次数不超过$n$的多项式.

从值上看, 代入节点$x_j$, 同时应用在$x_j$处有$P_n (x_j)=f(x_j)$, 可以得到
$
  Q_n (x_j) & =T_n (x_j)-P_n (x_j)=T_n (x_j)-f(x_j) \
            & =R_n (x_j)-rho_n (x_j)=-rho_n (x_j)
$

因此, $Q_n (x_j)!=0$, 我们在这里卡住了.

究其原因是, $Q_n (x_j)=0=>T_n (x_j)=f(x_j)$. 没法确保$T_n-P_n$在各个插值点均为0, 因为要插值的是$f$, 而不是$T_n$.

#corollary[但是从上面的式子, 我们可以发现, $Q_n$在节点上的值, 是*完全由泰勒余项决定*的.

  因此$ R_n (x)=Q_n (x)+rho_n (x) $

  其中, $Q_n$是一个次数不超过$n$的多项式, 它在节点上的值是$-rho_n (x_j)$.

  也就是说, 插值误差本质上是由泰勒余项传递出来的. 也即, *如果泰勒余项小, 则插值误差也小*, 误差来源于那$n$次多项式无法捕捉的那一部分.
]



== 改写

有趣的是, 由于$f(x)=T_n (x)+rho_n (x)$

那么对于$f$的插值多项式$P_n [f]$可以写成$ P_n [f]=P_n [T_n+rho_n] $

利用插值算子对函数值的线性关系, 可以得到$ P_n [f]=P_n [T_n]+P_n [rho_n] $

又因为$T_n$本身就是次数不超过$n$的多项式, 所以它的插值多项式其实就是它自己$ P_n [T_n]=T_n $

因此可得$ P_n [f]=T_n +P_n [rho_n] $

于是$ f-P_n [f] & =(T_n+rho_n)-(T_n+P_n [rho_n]) \
          & =rho_n-P_n [rho_n] $

原函数$f$的*插值误差*, 等于它的泰勒余项$rho_n$的插值误差.

插值多项式已经把$f$的$n$次多项式部分拟合了, 剩下的误差就来自于高阶剩余部分.

因为$rho_n (x)$是泰勒余项, 它在$x=a$附近是$O((x-a)^(n+1))$的, 所以可得$ f(x)-P_n [f](x)=rho_n (x)-P_n [rho_n](x) $

插值误差完全由一个"高阶小量函数"决定.

这里也隐含了插值误差应该是*$n+1$阶*量级的.

#thinking[搞笑的是, 我们上面的误差变成了$rho_n (x)-P_n [rho_n](x)$, 它当然在所有节点上都为0 (因为$P_n [rho_n]$是$rho_n$的插值多项式).]

#problem[但是我们却*又回到了原始的问题*, 它仍然是*两个一般函数减去它的插值多项式*, 并不是*两个多项式相减*.

  换句话说, 我们只是把问题从$f$转移到了$rho_n$.
]
== 结论

上面的推导过程可说明

$
  f-P_n [f]quad"只由"f"的"(n+1)"阶及以上部分决定"
$

因为所有$n$次及以下的多项式部分, 会被插值函数重建掉.

从算子角度看, 设$I$是恒等算子, $L_n$是"取$n$次插值多项式"的算子, 那么误差算子$I-L_n$会把所有次数不超过$n$的多项式全部消灭掉, 只能看见更高阶的部分.

因此余项公式里会出现$f^((n+1))$, 不会出现更低阶的导数.

同时, 虽然没法直接出现$omega_(n+1)$, 但是$rho_n$本身就是高阶小量函数, 所以$f-P_n [f]$也是由高阶部分主导. 这告诉我们误差*绝对不可能是低阶的*.

= 过渡与前文小结

再观察一下这个函数$ R_n (x)=f(x)-L_n (x)=(f^((n+1))(xi))/((n+1)!)omega_(n+1)(x),xi in (a,b) $

其中$omega_(n+1)(x)=Pi_(j=0)^n (x-x_j)$.

确实出现了我们说的$f^((n+1))$, 也会出现一个高阶小量函数. 但是显然, 我们接下来的目标就是给这个精确值求出来.

在前面, 我们主要做了下面的工作:

- 试图把原函数拆成"可控的多项式部分 + 麻烦的高阶剩余部分".

- 意识到插值误差其实只和高阶剩余部分有关.

  插值过程对所有$n$次及以下的多项式都是完全透明的. 这部分是会被原封不动地重建出来, 根本不会产生误差.

  高阶剩余部分才会留下来产生误差, 因此误差一定和$n+1$阶以及以上的信息有关, 这解释了为什么最后余项公式里会出现$f^((n+1))$.

- 既然误差已经被压缩到了这部分了, 那么能不能进一步把它刻画出来?

在这里, 单靠"展开成多项式, 再做减法"已经不够了. 因为剩下的对象依然是"一个一般函数减去它的插值多项式".

= 嵌入误差的函数

误差是没办法*直接算出来*的. 采用*构造一个带参的辅助函数*, 把误差嵌进去, 然后利用零点和导数的信息把这个参数解出来.

"如果一个量'直接算不出来', 但是知道它*应该和某些零点*, 某些*导数*有关, 那么最常见的策略就是---"

"把这个量*塞进一个新函数里*, 再让*新函数拥有一堆人为制造出来的好性质* (在若干点上为0, 或者导数好算), 通过*罗尔定理*, *中值定理*之类的工具, 把零点信息转换为导数信息, 再进行反推".

再梳理一下我们已知的:

$ R_n (x_j)=f(x_j)-P_n (x_j)=0quad forall x_j,j in 0,1,...,n $

$R_n$自己已经自带了$n+1$个零点. 如果再来一个新的零点, 那么就一共有$n+2$个零点.

如果这个函数足够光滑, 则可以*连续应用罗尔定理*$n+1$次, 就可以得到结果.

#thinking[
  这是因为, 我们已经知道$ R_n(x)=square f^((n+1))(square) $而罗尔定理恰好可以给出$square f^((n+1))(square)$的形式.
]


再重申下我们的目标: 找出$R_n (x)$的具体值.

将其写成某个*待定函数*乘上一个熟悉的函数: $ omega_(n+1)(t)=Pi_(j=0)^n (t-x_j) $

我认为这里的目标是把那$n+1$个零点显式定义出来, 剩下的余项则用下面的$K(x)$定义.

于是, 若$x$不等于任何节点, 则定义$ K=(R_n (x))/(omega_(n+1)(x)) $

#thinking[在这里的$K$可以看成待定*常数*. 换个角度, 针对某个*固定的*$x$, 将这个点上的误差值吸收到一个*常数*$K$中. 不能给$K$看成主动变化的函数, 而是由当前$x$, 求出比值的函数.]

辅助函数可以定义为:

$
  Phi(t)=f(t)-P_n (t)-K omega_(n+1) (t)
$

- 当$t=x_j$ (插值节点)时, 前两项本来就是0, 所以$Phi (t)=0$, 贡献了$n+1$个零点.

- 当$t=x$时, 根据$R_n (x)$在前面的定义, 仍然是0.

好消息是, $Phi$就有了$n+2$个零点:$ x_0,...,x_n,x $

原来的误差函数已经在$n+1$个零点上为0, 再减去一块恰到好处的$K omega_(n+1)(t)$, 使得它在目标点$x$也刚好变成0.


= 罗尔定理

#theorem[$Phi$有$n+2$个零点, 假设这些点按大小排列在某个区间内, 罗尔定理就保证这两个相邻零点之间有一点, 使得$Phi'(t)=0$.]

我们必然有$Phi^((n+1))(xi)=0$, 这是我们用$n+1$次罗尔定理得到的.

泰勒分解视角告诉我们最终结果应该和$(n+1)$阶信息有关, 现在罗尔定理指出了必然性.

= 求$n+1$阶导数具体值

对$Phi(t)$求$(n+1)$阶导, 可得$ Phi^((n+1))(t)=f^((n+1))(t)-P_n^((n+1))(t)-K omega_(n+1)^((n+1))(t) $

+ $P_n$是次数不超过$n$的多项式, 所以$P_n^((n+1))=0$.

+ $omega_(n+1)(t)=Pi_(j=0)^n (t-x_j)$, 不难发现它的$(n+1)$阶导数恒等于$(n+1)!$.

所以$ Phi^((n+1))(t)=f^((n+1))(t)-K (n+1)! $

立刻得出
$
  K=(f^((n+1))(xi))/(n+1)! =R_n(x)/(omega_(n+1)(x))
$


所以, $ R_n (x)=(f^((n+1))(xi))/(n+1)!omega_(n+1)(x) $

这样, 我们就得到了标准的拉格朗日型插值余项公式

$
  f(x)-P_n (x)=(f^(n+1)(xi))/(n+1)! Pi_(j=0)^n (x-x_j)
$
