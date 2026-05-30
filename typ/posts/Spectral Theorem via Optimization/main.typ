#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#show: project.with(
  title: "谱定理的最优化推导",
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
#let corollary = thmbox(
  "corollary",
  "Corollary",
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
#let thinking = thmbox(
  "thinking",
  "Thinking",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)

#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

#let av = $arrow(v)$
#let ax = $arrow(x)$
#let ay = $arrow(y)$
#let A1 = $bold(A)$
#let au = $arrow(u)$
#let av = $arrow(v)$

#let c-axis = rgb("#666666")
#let c-blue = rgb("#2a6f97")
#let c-red = rgb("#c1121f")
#let c-green = rgb("#588157")

#let fig-spectrum = figure(
  cetz.canvas({
    import cetz.draw: *

    set-style(
      mark: (
        transform-shape: false,
        fill: black,
      ),
    )

    line((-3.0, 0), (3.0, 0), stroke: c-axis + 0.7pt, mark: (end: "stealth"))
    line((0, -2.2), (0, 2.4), stroke: c-axis + 0.7pt, mark: (end: "stealth"))

    circle((0, 0), radius: 1.25, stroke: c-axis + 0.8pt)
    circle((0, 0), radius: (2.25, 0.95), stroke: c-blue + 1pt)

    line((0, 0), (2.05, 0), stroke: c-red + 0.9pt, mark: (end: "stealth"))
    line((0, 0), (0, 1.65), stroke: c-red + 0.9pt, mark: (end: "stealth"))

    content((3.5, 0), [$arrow(q)_1$])
    content((0, 3), [$arrow(q)_2$])
  }),
  caption: [单位圆在对称矩阵作用下会变成椭圆. 椭圆的主轴方向就是特征向量方向; 在这组方向上, 变换只表现为沿各轴的拉伸.],
)

#let fig-orthogonal = figure(
  cetz.canvas({
    import cetz.draw: *

    set-style(
      mark: (
        transform-shape: false,
        fill: black,
      ),
    )

    line((-2.5, 0), (2.8, 0), stroke: c-axis + 0.7pt, mark: (end: "stealth"))
    line((0, -2.3), (0, 2.7), stroke: c-axis + 0.7pt, mark: (end: "stealth"))

    line((0, 0), (2.0, 0), stroke: c-red + 0.95pt, mark: (end: "stealth"))
    line((0, 0), (0, 2.0), stroke: c-blue + 0.95pt, mark: (end: "stealth"))

    rect((0, 0), (0.24, 0.24), stroke: c-axis + 0.6pt)

    content((3, 0.1), [$au$])
    content((0, 3), [$av$])

    content((1.3, -0.42), [$A1 au = lambda au$])
    content((1.3, 1.65), [$A1 av = mu av$])
  }),
  caption: [若 $au, av$ 属于不同特征值, 那么对称性会推出 $au^T av = 0$. 几何上看, 就是不同特征方向天然互相垂直.],
)

#let fig-extremum = figure(
  cetz.canvas({
    import cetz.draw: *

    set-style(
      mark: (
        transform-shape: false,
        fill: black,
      ),
    )

    circle((0, 0), radius: 2.0, stroke: c-axis + 0.8pt)

    line((0, 0), (1.7, 1.05), stroke: c-red + 0.95pt, mark: (end: "stealth"))
    line((0, 0), (2.7, 1.67), stroke: c-blue + 0.95pt, mark: (end: "stealth"))

    line((1.2, 1.95), (2.25, 0.1), stroke: c-axis + 0.65pt)

    content((1.9, 1.5), [$ax^*$])
    content((3.3, 2.1), [$A1 ax^*$])
    content((0, -2.45), [极值点处只能沿法向变化])
  }),
  caption: [在单位球面上让 $ax^T A1 ax$ 取极值时, 沿切向已经不能继续增减, 因此 $A1 ax^*$ 只能沿球面的法向. 球面的法向就是 $ax^*$ 本身, 所以 $A1 ax^*$ 与 $ax^*$ 共线, 也就是特征向量条件.],
)

#let fig-invariant = figure(
  cetz.canvas({
    import cetz.draw: *

    set-style(
      mark: (
        transform-shape: false,
        fill: black,
      ),
    )

    line((-3.2, 0), (3.4, 0), stroke: c-axis + 0.7pt, mark: (end: "stealth"))
    line((0, -2.5), (0, 2.7), stroke: c-axis + 0.7pt, mark: (end: "stealth"))

    line((0, 0), (0, 2.1), stroke: c-red + 0.95pt, mark: (end: "stealth"))
    line((0, 0), (1.8, 0), stroke: c-blue + 0.95pt, mark: (end: "stealth"))
    line((0, 0), (3.0, 0), stroke: c-green + 0.95pt, mark: (end: "stealth"))

    content((0, 3), [$arrow(q)_1$])
    content((1.72, -0.34), [$ax$])
    content((3.0, -0.34), [$A1 ax$])
    content((3, 0.7), [$W = { ax : arrow(q)_1^T ax = 0 }$])
  }),
  caption: [找到一个特征向量 $arrow(q)_1$ 后, 与它正交的子空间 $W$ 在 $A1$ 作用下仍保持不变. 所以问题可以降到更低维空间中重复处理.],
)
// 在 Theorem 2.1 后，Thinking 2.1/2.2 前后都可以


// 在 Definition 3.1 讲完“交叉项没了，耦合也就没了”之后

// 在 5.2 求解里，刚推出 A x = lambda x 之后


// 在 Theorem 6.1 后


// #title[谱定理的最优化推导]

学特征值和特征向量的时候, 基本上就停留在了求$ det(bold(A)-lambda bold(I))=0 $

然后解特征值, 再解特征向量. 当时学的时候给出, 实对称矩阵不仅有特征值, 还能被正交对角化分解, 这就是谱定理.

但是书上没证, 就让我们记住它不仅可以分解, 还能产生出正交的特征向量.

现在发现还是得了解一下, 不然很多新知识都理解不了.

本文就来介绍介绍谱定理.

#v(50pt)

= 特征向量

若$ A1 av=lambda av $

则 $av$ 是特征向量, $lambda$ 是特征值. 即 $av$ 经过矩阵作用后, 只是长度被缩放了 $lambda$ 倍.

如果一个矩阵能找到 $n$ 个线性无关的特征向量, 那么我们就相当于找到了 $n$ 个"天然方向"作为新的坐标轴.// 如果这些方向还两两正交, 那就更漂亮了. 因为这套坐标系本身就很好用.

= 谱定理

实对称矩阵具有谱定理, 对称矩阵的全部作用可以被拆分成若干个互相垂直的"纯拉伸方向".

#theorem[实对称矩阵的谱定理

  设 $A1 in RR^(n times n)$, 且$ A1^T=A1 $则存在一个正交矩阵 $bold(Q)$ 和一个对角矩阵 $bold(bold(Lambda))$, 使得 $A1=bold(Q) bold(Lambda) bold(Q)^T$.

  换句话说, $A1$ 有一组标准正交的特征向量基. 也即, 对称矩阵完全可以由它的特征值和一组正交特征方向来描述.
]

#fig-spectrum

我们喜欢正交关系和对角矩阵, 不仅因为它们降低计算难度, 而且将其抽象为特征维度, 能反馈出特征之间不相关.

#thinking[矩阵本质上在做线性变换, 给定一个向量 $ax$, 矩阵 $A1$ 把它变成了 $A1 ax$. 一个变换矩阵可以对这个向量造成拉伸, 压缩, 旋转, 方向耦合等操作.

  其中, 方向耦合指的是在第一个坐标轴上的分量, 将其与第二个坐标轴进行联系. 即坐标之间互相搅在一起.

  但是对角矩阵就简单很多.]

谱定理告诉了我们, 存在一套特别好的坐标系, 在这套坐标系里, 对称矩阵的作用就是沿着若干*相互垂直*的方向对某个向量分别进行拉伸.

#thinking[
  注意是在这个*坐标系*中, 是从另一种坐标系观察向量乘法的操作.
]

= 对称矩阵

对称矩阵满足$ A1^T=A1 $
对于任意向量 $ax,ay in RR^(n times 1)$, 都有$ ax^T A1 ay=(A1 ax)^T ay=ax^T A1^T ay $
这里 $ax^T in RR^(1 times n),A1 in RR^(n times n), ay in RR^(n times 1)$, 因此 $ax^T A1 ay in RR^(1 times 1)$, 也就是一个标量.

那么显然标量的转置必然就是它自己. 于是$ ax^T A1 ay=(ax^T A1 ay)^T $

所以必然有$ ax^T A1 ay=ay^T A1^T ax $

由于 $A1$ 是对称矩阵$ ax^T A1 ay=ay^T A1 ax $


#definition[耦合程度 $B(ax,ay)$

  这是一个双线性型, 输入两个向量 $ax$, $ay$, 输出一个数.

  这个数衡量在矩阵 $A1$ 的作用下 (注意这里 $A1$ 为任意矩阵), $ax$ 对 $ay$ 的耦合度.

  观察

  $
    ax^T A1 ay=sum_(i ,j)a_(i j)x_i y_j
  $

  从这里看, 每一项都表示 $ax$ 的第 $i$ 个分量和 $y$ 的第 $j$ 个分量通过系数 $a_(i j)$ 发生了联系.

  特别地, 如果 $ax=ay$, 则变成了二次型$ ax^T A1 ax=sum_i a_(i i)x_i^2+sum_(i!=j)a_(i j)x_i x_j $

  如果 $A1$ 对称, 就可以写成$ ax^T A1 ax=sum_i a_(i i)x_i^2+2sum_(i<j)a_(i j)x_i x_j $

  这里的交叉项 $x_i x_j$ 就是耦合的体现. 一旦有这些项, 就表示第 $i$ 个坐标变动, 会和第 $j$ 个坐标一起影响总结果.

  但是如果换到特征向量基底后, 即$ ax=bold(Q) arrow(z),quad ax^T A1 ax=arrow(z)^T bold(Lambda) arrow(z)=sum_i lambda_i z_i^2 $

  交叉项没了, 耦合也就没了.

  因此用 $ax^T A1 ay$ 表示向量 $ax$ 对向量 $ay$ 在矩阵 $A1$ 作用下的耦合度. 即$ B(ax,ay)=ax^T A1 ay $
]

由 $A1$ 对称，有

$
  B(ax, ay) = ax^T A1 ay = (ax^T A1 ay)^T =ay^T A1^T ax = ay^T A1 ax = B(ay, ax)
$

故此时 $B$ 为*对称双线性型*. 这意味着耦合度与作用方向无关, $ax$ 对 $ay$ 的耦合度恒等于 $ay$ 对 $ax$ 的耦合度.

= 对称矩阵特征向量的关系<sec:4>

#fig-orthogonal
设$ A1 au=lambda au,quad A1 av=mu av,quad lambda!=mu $

其中 $au,av$ 是两个特征向量. 看内积 $au^T A1 av$, 一方面因为 $A1 av=mu av$, 所以$ au^T A1 av=au^T (mu av)=mu au^T av $

另一方面, 又因为 $A1$ 对称, 所以$ au^T A1 av=(A1 au)^T av=(lambda au)^T av=lambda au^T av $

于是$     lambda au^T av & =mu au^T av \
(lambda-mu)au^T av & =0 \
                   & stretch(=>)^(lambda!=mu)au^T av=0 $


#theorem[
  若 $A1$ 是实对称矩阵, 则属于不同特征值的特征向量必然正交.

  对称矩阵的不同特征方向, 天然彼此垂直.
]

= 求特征向量

@sec:4 指出了如果实对称矩阵有两个不同特征值, 对应的特征向量一定正交. 但这建立在特征值和特征向量存在的基础上.

// 但是谱定理还给出了一个内容: 这些特征向量不仅正交, 还能表示出一组基. 即它们能完全张成原始对角矩阵的*空间*.

#thinking[为了求特征向量, 我们当然可以直接解特征方程 $det(A1-lambda bold(I))=0$. 但是它在实数域上不一定有根.

  代数基本定理只保证它在复数域有根, 但是显然复特征值对于实矩阵缺乏直接几何意义.

  我们需要一条不依赖复数域的路径, 证明实对称矩阵必有*实*特征值, 并且这些特征方向能够*张成全空间*.]

回到耦合程度 $B(ax,ay)=ax^T A1 ay$, 一个自然的问题是, 一个向量在 $A1$ 的作用下, 自己和自己耦合能达到多大?

也就是研究二次型 $ f(ax)=B(ax,ax)=ax^T A1 ax $

#thinking[
  如果允许 $ax$ 任意缩放, $f(k ax)=k^2 f(ax)$, 它的值可以无限大或者无限小. 这意味着二次型数值大小没有信息量, 它只反映了向量的长度, 而非方向.

  在方向固定的前提下, 哪个方向能让自己和自己耦合达到最大?

  自然地, 需要限制长度. 即固定 $||ax||=1$.

  + 消除尺度自由度. 特征方程 $A1 ax=lambda ax$ 的解具有尺度不变性. 若 $ax$ 是特征向量, 则 $k ax$ 也是.

  + 保证极值存在. 见@sec:5:1.

  + 数值可比性. 不同方向上的二次型数值需要归一化才能比较.
]

// 同时约束 $||ax||=1$. 前面参数化的方法告诉我们它一定存在最值.

// 下面我们研究这个方向 $ax$ 的特殊性质.

// 也就是衡量向量 $ax$ 在矩阵 $A1$ 下, 自己和自己之间的作用强度.

// 现在不让 $ax$ 随便变大, 而是加上单位长度约束, 即 $||ax||=1$.

于是问题变成:$ max_(||ax||=1)ax^T A1 ax $


== 最值的存在性<sec:5:1>

=== 圆

先考虑简单情况. 单位圆上的任意向量可以写成:$ ax=mat(cos theta; sin theta),quad theta in[0,2pi] $

设前面的二次型为 $f(ax)=ax^T A ax$ . 它是一个关于 $theta$ 的函数:$ g(theta)=a_11 cos^2theta+2a_12cos theta sin theta+a_22sin^2theta $

这是一个一元连续函数, 定义域是闭区间 $[0,2pi]$.

由微积分基本事实: 闭区间上的连续函数一定存在最大值和最小值.

必然存在某个 $theta^* in[0,2pi]$, 使得 $g(theta^*)$ 最大. 对应的 $ax^*=(cos theta^*,sin theta^*)$ 就是使单位圆上使二次型达到最大值的向量.

=== 球

单位球面 $||ax||=1$ 可以用 $n-1$ 个角度参数化.

二次型 $f(ax)$ 变成关于这 $n-1$ 个角度的连续函数, 同时也有定义域限制.

连续函数在这个封闭的定义域上必有最大值. 结论一样成立.

// == 代数角度

// $
//   f(ax)=sum_(i,j)a_(i j)x_i x_j
// $

// 当 $||ax||=1$ 时, $|x_i|<=1$ 对所有 $i$ 成立, 所以:$ |f(ax)|<=sum_(i,j)|a_(i j)|dot|x_i|dot|x_j|<=sum_(i,j)|a_(i j)| $

// 这说明 $f(ax)$ 有上界. 然后取一列 $ax^((k))$ 使 $f(ax^((k)))$ 不断逼近上确界.

// 由于每个分量有界, 这列向量必有收敛子列,

== 求解

// 单位球面 $S={ax:||ax||=1}$ 是 $RR^n$ 中的紧集 (有界且封闭). 连续函数在紧集上必然有其最大值.

这是一个约束优化问题. 构造Lagrange函数, 其中 $eta$ 表示Lagrange乘子:$ L(ax,eta)=ax^T A1 ax-eta(ax^T ax-1) $

把 $ax^T A1 ax$ 写成分量形式看:$ ax^T A1 ax=sum_(i=1)^n sum_(j=1)^n a_(i j)x_i x_j $

对其中某一个分量 $x_k$ 求偏导. 这个双重求和里, 含 $x_k$ 的项有 $sum_(j=1)^n a_(k j)x_k x_j$ 和 $sum_(i=1)^n a_(i k)x_i x_k$.

对 $x_k$ 求导后:$ partial(ax^T A1 ax)/(partial x_k) & =sum_(j=1)^n a_(k j)x_j+sum_(i=1)^n a_(i k)x_i \
                                  & stretch(=)^"更换求和代号" sum_(i=1)^n a_(k i)x_i+sum_(i=1)^n a_(i k)x_i \
                                  & stretch(=)^(A1"对称")2sum_(i=1)^n a_(k i)x_i $

这正好是向量 $2 A1 ax$ 的第 $k$ 个分量. 所以$ nabla_(ax)(ax^T A1 ax)=2A1 ax $同理$ nabla_(ax)(ax^T ax-1)=2ax $因此极值点 $ax_*$ 满足$ 2A1 ax_*-2eta ax_*=0 $即$ A1 ax_*=eta ax_* $

单位球面上让二次型达到极值的方向, 必然是 $A1$ 的特征向量的方向.

因为 $||ax_*||=1$, 在上面等式两边左乘 $ax_*^T$, 得到$ ax_*^T A1 ax_*=eta ax_*^T ax_*=eta $

因此$ eta=ax_*^T A1 ax_* $

Lagrange乘子 $eta$ 恰好就是二次型在这个极值方向上的取值. 而又因为它满足 $A1 ax_*=eta ax_*$, 所以 $eta$ 也是 $A1$ 的一个特征值.

// #thinking[

//   #fig-extremum

//   不是巧合. 单位球面上任一点 $ax$ 的*切空间*, 是所有与 $ax$ 垂直的方向构成的子空间. $f(ax)$ 沿某个切向 $av$ (满足 $av^T ax=0$) 的方向导数是:$ nabla f(ax)^T av = 2(A1 ax)^T av $

//   在极值点, 沿任何切向移动都不能再增大或缩小 $f$, 所以方向导数必须对所有切向为0:$ (A1 ax)^T av=0,quad forall av perp ax $

//   这意味着 $A1 ax$ 与整个切空间垂直. 而切空间的正交补恰好是 $ax$ 自己张成的法线方向, 因此 $A1 ax$ 只能落在 $ax$ 的直线上, 即$ A1 ax=lambda ax $

//   极值点的定义就是"无法沿切向继续优化", 等价于 $A1 ax$ 没有切向分量, 等价于 $A1 ax$ 与 $ax$ 共线. 特征方程$A1-lambda bold(I)=0$也恰好刻画了这个几何条件, 两者是一回事.
// ]

// 在单位球面上, 极值点已经不能沿球面的切向继续增大了. 此时 $f(x)$ 的梯度只能垂直于球面.

// 球面 $||ax||=1$ 的法向量正是 $ax$ 本身. 另一方面, $ f(ax)=ax^T A1 ax $在 $A1$ 对称时, 它的梯度就是$ nabla f(ax)=2 A1 ax $

// 所以在极值点, $2A1 ax$ 与 $ax$ 必然共线, 即$ A1 ax parallel ax $

// 也即$ A1 ax=lambda ax $

#corollary[
  单位球面上二次型 $ax^T A1 ax$ 的极大/极小方向, 一定是特征向量方向; 极值的数值也恰好就是特征值.
]

#theorem[实对称矩阵的特征值必为实数. 这是因为, Lagrange乘子法处理的是实值函数在实约束下的机制问题. 上面的 $eta$ 作为Lagrange乘子, 它一定是实数.]


// #proof[
//   更一般地, 设 $A1 au=lambda au,au != arrow(0)$, 取共轭转置:$ au^*A1=lambda^* au^* $右乘$au:$$ au^*A1 au=lambda^* au^* au $

//   但由 $A1 au=lambda au$ 又有 $au^* A1 au=lambda au^* au$, 因此$ lambda^* ||au||^2=lambda||au||^2=>lambda=lambda^* $
//   因此 $lambda in RR$.
// ]

= 迭代处理

#fig-invariant

现在知道了实对称矩阵 $A1$ 至少存在一个单位特征向量 $arrow(q_1)$ 满足$ A1 arrow(q_1)=lambda_1 arrow(q_1) $

找到一个特征方向后, 可以把这个方向拿掉, 在剩下的垂直空间里继续找新的特征方向. 考虑子空间$ W={ax in RR^(n times 1):arrow(q_1)^T ax=0} $
也就是所有与 $arrow(q_1)$ 垂直的向量组成的空间. 方向自由度减少了1, 是一个 $n-1$ 维子空间.

#thinking[这里注意, $ax$ 向量本身是 $n$ 维, 但是它自由度只有 $n-1$, 因为它要保持与 $arrow(q_1)$ 垂直.]

取任意 $ax in W$, 即 $arrow(q_1)^T ax=0$. 因为 $A1$ 对称, 所以$ arrow(q_1)^T A1 ax=(A1 arrow(q_1))^T ax=(lambda_1 arrow(q_1))^T ax=lambda_1 arrow(q_1)^T ax=0 $

所以, $A1 ax in W$. 如果一个向量本来就垂直于 $arrow(q_1)$, 那么它经过 $A1$ 作用后, 它仍然垂直于 $arrow(q_1)$. $W$ 这个空间在 $A1$ 的作用下, 不会跑出去.

// #theorem[
//   若 $A1$ 是对称矩阵, 且 $arrow(q_1)$ 是它的特征向量, 则正交补空间 $W=arrow(q_1)^perp$ 在 $A1$ 作用下保持不变.
// ]<theorem61>

// 这样, 我们可以在这 $n-1$ 维空间里继续研究 $A1$.

== 对称性

因为 $W$ 在 $A1$ 作用下保持不变, 所以我们可以只在 $W$ 里继续研究同一个问题. 现在不再看整个 $RR^n$, 而是看所有满足 $ax perp arrow(q)_1$ 的方向.

在这个 $n-1$ 维空间里, 继续考虑单位向量上的二次型:$ max_(ax in W,||ax||=1)ax^T A1 ax $

由于 $W$ 里的单位球面仍然是一个封闭有界的集合, 而 $ax^T A1 ax$ 仍然是连续函数, 所以最大值仍然存在. 设最大值在 $arrow(q)_2$ 处取得.

和前面完全一样, 在 $W$ 内部做约束优化, 也会得到$ A1 arrow(q)_2=lambda_2 arrow(q)_2 $

也即, $arrow(q)_2$ 也是 $A1$ 的特征向量.

// $W$ 上的内积就是 $RR^n$ 标准内积的限制. 即$ angle.l ax,ay angle.r_W=ax^T ay $

// 取任意 $ax, ay in W$, 则

// $ angle.l A1|_(W)(ax), ay angle.r_W=(A1 ax)^T ay $

// 利用 $A1$ 在 $RR^n$ 上对称$ (A1 ax)^T ay=ax^T A1^T ay=ax^T A1 ay=ax^T (A1 ay)=angle.l ax,A1|_(W)(ay)angle.r_W $

// 所以$ angle.l A1|_(W)(ax),ay angle.r_W=angle.l ax,A1|_(W)(ay)angle.r_W $

// 上面就是 $W$ 上对称算子的定义.

// #proof[
//   取 $W$ 的一组标准正交基 $au_1,...,au_n$, 令 $ U=mat(au_2, ..., au_n) in RR^(n times (n-1)) $
//   则 $A1|_W$ 在这组基下的矩阵表示为$ M=U^T A1 U $并且$ M^T=(U^T A1 U)^T=U^T A1^T U=U^T A1 U=M $
//   所以 $M$ 是 $(n-1)times(n-1)$ 的对称矩阵.
// ]

// 既然 $W=arrow(q_1)^perp$ 在 $A1$ 下不变, 那么 $A1$ 在 $W$ 上的限制, 仍然是一个线性变换. 而且它仍然"对称".
且这个特征向量与第一个天然正交.

// == 特征值和特征向量的存在性

// 因为限制后的算子仍然对称, 而对称性本身就保证了特征值一定存在.

// #proof[
//   用数学归纳法. 设 $k$ 维实内积空间上的对称线性算子, 一定至少有一个实特征值和对应的特征向量.

//   *基例* 当 $k=1$ 时, $1 times 1$ 的矩阵就是实数 $a$, 它作用在向量 $ax$ 上就是 $a ax=a ax$. 所以 $a$ 本身就是特征值, 任意非零向量都是特征向量. 显然成立.

//   *归纳步骤* 假设对 $k=n-1$ 成立, 证明对 $k=n$ 也成立.

//   + 对 $n$ 维空间上的对称矩阵 $A1$, 首先证明它至少有一个实特征值 $lambda_1$ 和对应的单位特征向量 $arrow(q)_1$.

//     特征多项式在复数域内有根, 再利用 $A1$ 的对称性来证明这个根必为实数. (代数基本定理).

//   + 构造 $W=arrow(q_1)^perp$, 这是 $n-1$ 维子空间. 证明了 $A$ 把 $W$ 映射到了 $W$.

//   + 限制后的算子 $A|_W$ 仍然是对称的.

//   + 现在 $A|_W$ 是 $n-1$ 维空间上的对称算子. 根据归纳假设, 它一定有至少一个实特征值 $lambda_2$ 和特征向量 $arrow(q_2)in W$.

//   + 由于 $arrow(q_2)in W$, 则它也满足 $arrow(q_2)perp arrow(q_1)$.

//   + 对 $arrow(q_2)$ 的正交补空间继续降维, 重复这个过程, 直到最后 1 维空间.
// ]

// 对于任意 $au,av in W$, 仍然有$ au^T A1 av=(A1 au)^T av=av^T A1 au $

== 重复降维

现在已经有两个互相正交的单位特征向量 $arrow(q_1),arrow(q_2)$.

接下来考虑同时垂直于它们的空间:$ W_2={arrow(x) in RR^n:arrow(q_1)^T ax=0,arrow(q)_2^T ax=0} $

同样可以证明, 如果 $ax in W_2$, 那么 $A1 ax in W_2$.

原因和刚才一样, 对 $i=1,2$, 都有$ arrow(q)_i^T A1 ax=(A1 arrow(q)_i)^T ax=(lambda_i arrow(q)_i)^T ax=lambda_i arrow(q)_i^T arrow(x)=0 $

所以 $A1 ax$ 仍然垂直于 $arrow(q)_1,arrow(q)_2$.

于是我们可以继续在 $W_2$ 里找二次型的极值方向, 得到第三个单位特征向量 $arrow(q)_3$.

+ 找到一个单位特征向量 $arrow(q)_i$.

+ 看所有与已有特征向量都垂直的方向.

+ 这个垂直空间在 $A1$ 作用下仍然保持不变.

+ 在这个更低维空间里继续最大化 $ax^T A1 ax$.

+ 得到新的单位特征向量.

最终就能得到一组标准正交向量$ arrow(q_1),arrow(q_2),...,arrow(q_n) $

每个都满足$ A1 arrow(q_i)=lambda_i arrow(q_i) $

拼成矩阵$ bold(Q)=mat(arrow(q_1), arrow(q_2), ..., arrow(q_n)) $

由于它们标准正交, 所以$ bold(Q)^T bold(Q)=bold(I) $
即 $bold(Q)$ 是正交矩阵.

另一方面$ A1 bold(Q)=mat(A1 arrow(q_1), A1 arrow(q_2), ..., A1 arrow(q_n))&=mat(lambda_1 arrow(q_1), lambda_2 arrow(q_2), ..., lambda_n arrow(q_n))\ &=bold(Q) bold(Lambda) $
左乘 $bold(Q)^T$, 可得$ bold(Q)^T A1 bold(Q)=bold(Lambda) $
即谱定理得证$ A1=bold(Q) bold(Lambda) bold(Q)^T $


// - 在单位球面上研究二次型 $x^T A x$.

// - 极值点满足梯度与球面法向平行, 所以得到特征向量.
// - 对称性保证不同特征值对应的特征向量正交.
// - 对称性还保证已找到特征向量的正交补空间保持不变.
// - 因此可以在更低维子空间中重复这个过程.
// - 最终得到一组标准正交特征向量基, 从而正交对角化.
