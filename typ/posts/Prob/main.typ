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

// #title[
//   平方体系下的聚类分析与参数估计
// ]

作者: Vkango, OpenAI GPT-5.4

= 引入

本文集中解决我在学习概率论与数理统计过程中遇到的下面的定义的问题:

- 中心化: 减去均值.

- 标准化: 除以标准差.

- 方差: 偏离平方和.

- 样本方差: 除以$n-1$.

- 相关系数: 协方差除以标准差的积.

- 聚类前为何要中心化和标准化.

我在学习过程中遇到的困惑是, 这些定义看起来都是为了让数据更好地服从正态分布, 但它们之间的关系和背后的原理并不清晰. 通过本文, 我希望能够从平方体系的角度来理解这些定义, 并且通过一些例子来说明它们的作用.

#problem[
  我们到底在用什么方式衡量"两个*样本*像不像", "一个变量*波动*大不大", "一个变量和另一个变量*是否相关*"?
]

实际上我们都是采用了一个"平方体系"来理解数据.

= 数据之间的比较

考虑我们在做聚类问题, 把*相似的人*归成一类.

那么*如何定义"相似"*?

#thinking[从另一个角度理解"相似", 也可以理解为这两个样本的距离. 空间中样本点之间离得近, 自然就相似.]

自然的定义是欧氏距离的平方.

$
  d(x_i,x_k)=sum_j (x_(i j)-x_(k j))^2
$

表示把每个变量上的差异平方后求和.

优点: 平移不变性. 如果某个变量对所有样本整体都加上同一个常数, 那么任意两个样本在这一维上的差值并不会变化, 样本之间的距离也不会变化.

这里实际上存在着一个很合理的需求, 而欧氏距离恰好天然满足: *整体平移不应该改变样本之间的相似性*.

#problem[

  "差10"的不同场景:

  - 一个变量本身就只在$[0,20]$内波动, 那么差10已经很大.

  - 如果另一个变量在$[0,10000]$内波动, 那么差10几乎可以忽略.

  两两比较解决了"谁和谁近". 但是, "近"是在怎样的整体背景下被解释的?
]

// 研究下面的问题时, 欧氏距离的平方则无法给出答案:

// #problem[
//   + 某个变量在这批样本里"波动大不大"?

//   + 某个样本在这一维上"偏的多不多"?

//   + 某个变量是否应该在距离中占更大权重?
// ]

因此不仅需要比较样本之间的差异, 还需要给每个变量建立一个*相对评价体系*.

- 什么是这个变量的典型水平?

- 一个样本偏离这个典型水平有多远?

- 这种偏离在所有样本里是算大还是算小?

== 如何为一个变量选择基准?

目标: 选择一个基准$c$, 使得每个样本都可以被改写成$x_i-c$. 它衡量出, 相对于基准, 每个样本在这一维上偏离了多少.

#problem[
  选择什么样的基准才合理?

  选择0作为基准, 但0通常只是坐标原点, 不一定代表这个变量在样本中的典型位置.

  选择某个样本的值作为基准, 则会过于依赖某一个观测, 缺乏整体性.

  我们更希望这个基准能够代表"所有样本共同围绕的位置".

  所以问题变成: 能否找到一个$c$, 使得所有样本相对于它的总偏离尽量小?
]


接住前面欧氏距离的定义, 这个总偏离就可以定义为

$
  L(c)=sum_(i=1)^n (x_i-c)^2
$

如果把$c$当作变量的代表位置, 那么所有样本围绕它的总平方偏差有多大?

目标函数:$ min_c sum_(i=1)^n (x_i-c)^2 $

求导:$ d/(d c)sum_(i=1)^n (x_i-c)^2=-2sum_(i=1)^n (x_i-c) $

导数为0, 得$ sum_(i=1)^n (x_i-c)=0 $

因此, $ n c=sum_(i=1)^n x_i $

得最优解: $ c=overline(x)=1/n sum_(i=1)^n x_i $

使用平方的方式求解很顺畅, 如果使用绝对值的方式, 求导就会遇到分段函数, 反而不太好求解.


== 中心化

找到了最优基准$overline(x)$, 则可以把每个样本改写成$x_i-overline(x)$, 把原始数据$x_i$改写成了样本在*这一维上, 相对于整体中心偏了多少*.

于是得到了一个新的表达系统:

- 正值: 高于整体中心.

- 负值: 低于整体中心.

- 绝对值越大: 离整体中心越远.

#problem[
  中心化没有解决所有问题. 即使两个变量各自都减去了各自的均值, 它们的偏离仍然可能*完全不在*同一个尺度上.

  如果一个变量的值域是$[0,1]$, 另一个变量的值域是$[0,10000]$, 那么它们的中心化后的偏离程度也会有很大的差异. 这就导致在计算样本之间的距离时, 后者的影响可能会被前者掩盖掉.
]

下面研究它相对于这个变量自身通常的*波动水平*, 到底偏了多少.

== 为变量选择一个尺度

中心化之后, 每一个样本都写成了$x_i-overline(x)$, 那么接下来的目标就是:

选择一个尺度$s$, 使得每个样本都可以被改写成$ (x_i-overline(x))/s $它衡量出, 相对于这个变量自身的典型波动水平, 每个样本在这一维上偏离了多少.

如果$s$选择合理, 则$(x_i-overline(x))/s=2$表示"高出了2个单位尺度", 而$(x_i-overline(x))/s=-1$表示"低了1个单位尺度". 不同变量上的偏离就可以放到同一个相对标准下比较.

#problem[
  - 如果直接取值域长度作为尺度, 则太依赖极端值, 不稳定.

  - 如果随便选一个常数, 只是人为调整单位, 没有反映变量本身的波动结构.

]

方案1:$ 1/n sum_(i=1)^n (x_i-overline(x)) $

不可能, 因为正负偏离相互抵消. 如果我们想衡量距离中心多远, 就不能把直接偏离相加.

方案2: 取绝对值, $1/n sum abs(x_i-overline(x))$

方案3:

用中心化后的平方偏离来度量整体波动. 定义$ V=1/n sum_(i=1)^n (x_i-overline(x))^2 $衡量*所有样本围绕中心$overline(x)$的平均平方偏差有多大*.

推荐使用方案3, 因为它具有更好的数学性质, 例如可微性, 以及与欧氏距离的平方的一致性. 方案2虽然也可以衡量偏离程度, 但在数学处理上会更复杂一些.

#definition[*方差*

  $ "Var"(x)=1/n sum_(i=1)^n (x_i-overline(x))^2 $描述了这个变量的整体波动程度.]

#problem[

  方差虽然很好地继承了平方体系, 但它的单位是原变量单位的平方.
  这使得它不太适合直接拿来作为"偏离的自然单位".
]

使用方差的平方根作为尺度, 就得到了标准差.

标准化后的欧氏距离是:
$
  d(x_i,x_k)=sqrt(sum_(j=1)^p ((x_(i j)-x_(k j))/ s_j)^2)
$

== 相关系数

