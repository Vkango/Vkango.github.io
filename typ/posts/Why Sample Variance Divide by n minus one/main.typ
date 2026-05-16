#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#import "@preview/cetz:0.4.2": canvas
#import cetz.draw: circle, content, line
#show: project.with(
  title: "从自由度到几何投影理解样本方差为什么除以 n - 1",
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
// #title[向量直觉理解样本方差为何除以$n-1$]

// 作者: Vkango, OpenAI GPT-5.4, Google Gemini 3.1 Pro
= 引入

样本方差:
$
  s^2=1/(bold(n-1)) sum_(i=1)^n (X_i-overline(X))^2
$

- 当总体均值$mu$未知时, 用样本均值$overline(X)$代替$mu$.

- 这个代替会让离差平方和系统性偏小. 且偏小的比例是可以被精确算出来的$ EE[sum_(i=1)^n (X_i-overline(X))^2]=(n-1)sigma^2 $

本文要解决的就是怎么算出来的这个$(n-1)$, 以及其对应的理解.

= 自由度

== 理论

"自由变化"的方向数量. 当把数据中心化以后, 即$ X_1-overline(X),X_2-overline(X),...,X_n-overline(X) $

要求它们必须满足这个约束: $ sum_(i=1)^n (X_i-overline(X))=0 $

前$n-1$个中心化值一旦决定, 第$n$个就不能再自由选了, 它必须等于前面那些负和.

#thinking[

  已经观察到了这一组样本值: $x_1,...,x_n$, 定义样本均值$ overline(X)=1/n sum_(i=1)^n X_i $

  构造中心化后的量:$ r_i=X_i-overline(X) $

  这些$r_i$一定满足$ sum_(i=1)^n r_i=0 $

  也就是说, 在把原始数据经过中心化变换后, 得到的新变量组$r_i$彼此之间*不再独立*!

  #thinking[
    原始样本$X_1,...,X_n$可以是独立的, 但是中心化后的残差$R_i=X_i-overline(X)$通常就不独立了, 因为它们共享同一个$overline(X)$.
  ]

]


虽然原始有$n$个独立样本, 但是中心化后却只剩下$n-1$个自由方向, 因为我们对$n$个自由样本做了减去共同均值的操作.

== 本质

独立采样之后, 做一个统计变换, 会产生依赖关系. 因为这个变换本身就给它们耦合起来了.

== 几何直觉

假设原始样本向量$ bold(x)=(x_1,...,x_n)in RR^n $

#definition[
  在$n$维空间$RR^n$中, 向量$bold(1)=(1,1,...,1)^T$是一条从原点出发的射 (直) 线. 它代表"*所有样本值都完全相等*"的状态, 可以理解成"无波动方向". 也即$x_1=x_2=...=x_n$.
]

因为每个坐标都可以独立取值, 所以它就在$n$维空间里.

中心化相当于减去沿着$(1,1,...,1)$方向的那一部分$ bold(x)|-> bold(x)-overline(X)bold(1) $

#thinking[
  $bold(x)$很少直接落在$bold(1)$上, 从向量分解的角度, 它可以包含两种信息:

  + 沿着$bold(1)$方向的分量, 这反映了数据整体的平均水平, 实际上就是均值.

  + 偏离$bold(1)$方向的分量, 反映了数据内部的参差不齐, 也就是波动/方差.
]

得到的新向量落在超平面$ H={bold(z) in RR^n: sum_(i=1)^n z_i=0} $

这个平面维数是$n-1$. 如图所示:



#let O = (0, 0)
#let R = (3.4, 0)
#let X = (3.4, 2.4)

#figure(caption: [正视投影图. 如图, $bold(1)$方向的分量没了, 自由度$-1$.], [#canvas({
  line(
    (-1.2, 0),
    (6.2, 0),
    stroke: (paint: rgb("#60a5fa"), thickness: 2pt),
  )
  content(
    (-1.4, -1.5),
    [$H = { bold(z) in RR^3 : z_1 + z_2 + z_3 = 0 }$],
    anchor: "north-west",
  )
  // 1 方向
  line(
    (R.at(0), -0.9),
    (R.at(0), 3.2),
    stroke: (paint: gray, dash: "dashed"),
  )
  content(
    (R.at(0) + 0.15, 3.0),
    [$bold(1)$ 方向],
    anchor: "west",
  )

  // 绿色
  line(
    O,
    R,
    stroke: (paint: rgb("#15803d"), thickness: 1.8pt),
    mark: (end: ">"),
  )
  content(
    (1.9, 0.18),
    [$bold(x) - overline(X) bold(1)$],
    anchor: "south",
  )

  line(
    R,
    X,
    stroke: (paint: gray, thickness: 1.4pt),
    mark: (end: ">"),
  )
  content(
    (R.at(0) + 0.2, 1.2),
    [$overline(X) bold(1)$],
    anchor: "west",
  )

  // 红色
  line(
    O,
    X,
    stroke: (paint: rgb("#dc2626"), thickness: 1.9pt),
    mark: (end: ">"),
  )
  content(
    (X.at(0) - 2, X.at(1) - 0.8),
    [$bold(x)$],
    anchor: "west",
  )

  // 点
  for P in (O, R, X) {
    circle(P, fill: black, radius: 3pt, stroke: none)
  }

  content((-0.1, 0.3), [$O$], anchor: "south-west")
})])<fig1>


= 自由度与方差的关系<sec:3>

样本均值$overline(X)$是专门从这组数据里选出来的, 让平方偏差和最小的中心.

$
  overline(X)=arg min_c sum_(i=1)^n (X_i-c)^2
$

#proof[
  目标函数:$ min_c sum_(i=1)^n (X_i-c)^2 $

  求导:$ d/(d c)sum_(i=1)^n (X_i-c)^2=-2sum_(i=1)^n (X_i-c) $

  导数为0, 得$ sum_(i=1)^n (X_i-c)=0 $

  因此, $ n c=sum_(i=1)^n X_i $

  得最优解: $ c=overline(X)=1/n sum_(i=1)^n X_i $
]

不难发现:

#corollary[
  对于任何别的中心, 特别是总体均值$mu$, 总有$ sum_(i=1)^n (X_i-overline(X))^2<=sum_(i=1)^n (X_i-mu)^2 $
]

用真实中心$mu$算偏差平方和会比用样本均值$overline(X)$算误差平方和大.

#thinking[
  真实中心$mu$理解为"客观波动", 而用样本均值$overline(X)$理解成$overline(X)$是*专门贴着这组数据选出来的*, 所以偏差和被压小了.
]

= 压小的值: 离差平方和分解

== 理论

假设可以将总波动拆分成两部分:

- 一部分是*数据内部的波动*, 即各点相对于样本均值$overline(X)$的波动

- 一部分是*样本中心整体偏移的程度*, 即样本均值$overline(X)$相对于$mu$的偏离.

那么可以构造出核心恒等式:

$
  sum_(i=1)^n (X_i-mu)^2=sum_(i=1)^n (X_i-overline(X))^2+K
$

目的是算出$K$.

$
           sum_(i=1)^n (X_i-mu)^2 & =sum_(i=1)^n X_i^2-2mu sum_(i=1)^n X_i +n mu^2 \
  sum_(i=1)^n (X_i-overline(X))^2 & =sum_(i=1)^n X_i^2-2overline(X)sum_(i=1)^n X_i+n overline(X)^2 \
  sum_(i=1)^n (X_i-overline(X))^2 & stretch(=)^(sum_(i=1)^n X_i=n overline(X))sum_(i=1)^n X_i^2-n overline(X)^2
$
所以
$
  K & =[sum X_i^2-2mu sum X_i+n mu^2]-[sum X_i^2-n overline(X)^2] \
    & stretch(=)^(sum X_i=n overline(X))-2mu dot n overline(X)+n mu^2+n overline(X)^2 \
    & =n overline(X)^2-2n overline(X)mu+n mu^2 \
    & =n(overline(X)^2-2overline(X)mu+mu^2) \
    & =n(overline(X)-mu)^2
$

发现$K$确实是整体中心偏移的额外量, 也发现: 偏移与样本量$n$成正比, 也与偏移距离成正比.

#theorem[*离差平方和分解*

  $
    sum_(i=1)^n (X_i-mu)^2=sum_(i=1)^n (X_i-overline(X))^2+n(overline(X)-mu)^2
  $

  少掉的波动, 就是样本均值自己拟合数据吸收的部分.
]

== 几何定性



// $
//   (overline(X)-mu)^2
// $

// 如@fig1 所示, 实际上$(overline(X)-mu)^2$恰好就对应了$x-overline(X)bold(1)$这个投影向量的平方长度.

// #thinking[
//   需要进一步指出的是, 此处涉及到视角的变换. @fig1 更侧重于展示各个样本之间的减法关系, 我们这里是对整体统计值做的变化.
// ]
//

=== 宏观视角

$
  (overline(X)-mu)^2
$

如@fig1 所示, 实际上$(overline(X)-mu)bold(1)$恰好就对应了沿$bold(1)$方向的均值偏移分量.

#thinking[
  需要进一步指出的是, 此处涉及到视角的变换. @fig1 更侧重于展示各个样本之间的减法关系, 我们这里是对整体统计值做的变化.
]

=== 微观视角

对每个样本$X_i$, 都有$ X_i-mu=(X_i-overline(X))+(overline(X)-mu) $

每个点相对基准$mu$的偏差, 都可以拆成:

+ 样本点相对于样本均值的偏差: $X_i-overline(X)$.

+ 样本均值相对于总体中心$mu$的偏差: $overline(X)-mu$.


设$bold(x)=(X_1,...,X_n) in RR^n, quad bold(1)=(1,...,1)$

放在$n$维空间合并来看, 即$ bold(x)-mu bold(1)=(bold(x)-overline(X)bold(1))+(overline(X)-mu)bold(1) $

满足正交性:

$
  sum_(i=1)^n (X_i-overline(X))=0=>(bold(x)-overline(X)bold(1))dot bold(1)=0.
$


所以, 一部分沿着$bold(1)$的方向, 另一部分落在超平面.


// #let O = (0, 0)
// #let R = (3.4, 0)
// #let X = (3.4, 2.4)

// #figure(
//   caption: [$bold(x)-overline(bold(x))bold(1)$在超平面$H$内, $(overline(bold(x))-mu)bold(1)$沿$bold(1)$方向, 二者正交],
//   [#canvas({
//     line(
//       (-1.2, 0),
//       (6.2, 0),
//       stroke: (paint: rgb("#60a5fa"), thickness: 2pt),
//     )
//     content(
//       (-1.4, -1.5),
//       [$H = { z in RR^3 : z_1 + z_2 + z_3 = 0 }$],
//       anchor: "north-west",
//     )
//     // 1 方向
//     line(
//       (R.at(0), -0.9),
//       (R.at(0), 3.2),
//       stroke: (paint: gray, dash: "dashed"),
//     )
//     content(
//       (R.at(0) + 0.15, 3.0),
//       [$bold(1)$ 方向],
//       anchor: "west",
//     )

//     // 绿色
//     line(
//       O,
//       R,
//       stroke: (paint: rgb("#15803d"), thickness: 1.8pt),
//       mark: (end: ">"),
//     )
//     content(
//       (2, 0.18),
//       [$bold(x)-overline(bold(x)) bold(1)$],
//       anchor: "south",
//     )

//     line(
//       R,
//       X,
//       stroke: (paint: gray, thickness: 1.4pt),
//       mark: (end: ">"),
//     )
//     content(
//       (R.at(0) + 0.2, 1.2),
//       [$(overline(bold(x))-mu) bold(1)$],
//       anchor: "west",
//     )

//     // 红色
//     line(
//       O,
//       X,
//       stroke: (paint: rgb("#dc2626"), thickness: 1.9pt),
//       mark: (end: ">"),
//     )
//     content(
//       (X.at(0) - 3.5, X.at(1) - 0.8),
//       [$bold(x)-mu bold(1)$],
//       anchor: "west",
//     )

//     // 点
//     for P in (O, R, X) {
//       circle(P, fill: black, radius: 3pt, stroke: none)
//     }

//     content((-0.1, 0.3), [$O$], anchor: "south-west")
//     // content((3.6, 2.2), [$overline(bold(x))bold(1)$], anchor: "south-west")
//   })],
// )<fig2>

#thinking[

  #let O = (0, 0)
  #let R = (0, 0)
  #let P = 2.25
  #let R1 = (P, P)
  #let X = (3.4, 1)
  #let X1 = (3.4, 3.4)
  #figure(
    caption: [$H = { z in RR^2 : z_1 + z_2=0 }$],
    [#canvas({
      line(
        (-1.2, 0),
        (6.2, 0),
        stroke: (paint: rgb("#60a5fa"), thickness: 2pt),
      )
      // 1 方向
      line(
        (R.at(0), -0.9),
        (R.at(0), 3.2),
        stroke: (paint: gray, dash: "dashed"),
      )
      content(
        (R.at(0) + 1, 3.0),
        [$bold(1)$ 方向],
        anchor: "west",
      )


      line(
        R,
        X1,
        stroke: (paint: gray, thickness: 1.4pt),
        mark: (end: ">"),
      )

      // 绿色
      line(
        O,
        R1,
        stroke: (paint: rgb("#15803d"), thickness: 1.8pt),
        mark: (end: ">"),
      )

      line(
        R1,
        X,
        stroke: (paint: rgb("#721580"), thickness: 1.8pt),
        mark: (end: ">"),
      )

      content(
        (3.8, 1.8),
        [$bold(x)-overline(bold(x)) bold(1)$],
        anchor: "south",
      )

      content(
        (R.at(0) + 0.4, 1.5),
        [$overline(bold(x)) bold(1)$],
        anchor: "west",
      )

      // 红色
      line(
        O,
        X,
        stroke: (paint: rgb("#dc2626"), thickness: 1.9pt),
        mark: (end: ">"),
      )
      content(
        (X.at(0) + 0.3, X.at(1)),
        [$bold(x)$],
        anchor: "west",
      )

      // 点
      for P in (O, R, X) {
        circle(P, fill: black, radius: 3pt, stroke: none)
      }

      content((-0.1, 0.3), [$O$], anchor: "south-west")
      // content((3.6, 2.2), [$overline(bold(x))bold(1)$], anchor: "south-west")
    })],
  )<fig2>

  @sec:3 中我们证明了$ min_c sum (X_i-c)^2=>c=overline(X) $

  我们可以把$c$视作$c bold(1)$, 那么问题就变成了: 在这个$bold(1)$方向上, 找出伸缩长度$c$, 使得点$c bold(1)$到观测向量$X_i$的距离最小.

  显然, 点到直线最短距离, 就是垂线.

  因此, 最优点$overline(bold(x))bold(1)$就是$x$在均值直线上的正交投影. 既然是投影点, 那么垂线向量 ($bold(x)-overline(bold(x))bold(1)$) 必然与$bold(1)$方向绝对正交.
]




所以平方长度分解为$ ||bold(x)-mu bold(1)||^2=||bold(x)-overline(bold(x))bold(1)||^2+||(overline(bold(x))-mu)bold(1)||^2 $

最后一项$ ||(overline(bold(x))-mu)bold(1)||^2=(overline(bold(x))-mu)^2||bold(1)||^2=n(overline(bold(x))-mu)^2 $

这和定理是一致的.

= $n-1$的来源

对上面的恒等式取期望

$
  EE[sum_(i=1)^n (X_i-mu)^2]=EE[sum_(i=1)^n (X_i-overline(X))^2]+n EE[(overline(X)-mu)^2]
$

如果$X_1,...,X_n$独立同分布, 方差都是$sigma^2$, 则$ EE[sum_(i=1)^n (X_i-mu)^2]=n sigma^2 $

且$ EE[(overline(X)-mu)^2]="Var"(overline(X))=sigma^2/n $

回代$ n sigma^2=EE[sum_(i=1)^n (X_i-overline(X))^2]+n dot sigma^2/n $

所以$ EE[sum_(i=1)^n (X_i-overline(X))^2]=(n-1)sigma^2 $

于是$ EE[1/(n-1) sum_(i=1)^n (X_i-overline(X))^2]=sigma^2 $

因此, 只有除以$n-1$, 它才是总体方差的无偏估计.
