#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#show: project.with(
  title: "从PCA到Robust PCA",
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
#let thinking = thmbox(
  "thinking",
  "Thinking",
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

#let example = thmbox("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

#let A1 = $bold(A)$
#let D1 = $bold(D)$
#let U1 = $bold(U)$
#let S1 = $bold(inline(sum))$
#let V1 = $bold(V)$
#let X1 = $bold(X)$
#let rank = $"rank"$
#let aw = $arrow(w)$
#let ax = $arrow(x)$
#let ay = $arrow(y)$


// #title[从PCA到Robust PCA]

前面从谱定理和约束最优化出发, 解析了对称矩阵的特征值, 特征向量特殊性. 本文介绍下定理内容的落地.

先回顾一下定理内容:


#theorem[实对称矩阵的谱定理

  设 $bold(A) in RR^(n times n)$, 且$ bold(A)^T=bold(A) $则存在一个正交矩阵 $bold(Q)$ 和一个对角矩阵 $bold(bold(Lambda))$, 使得 $bold(A)=bold(Q) bold(Lambda) bold(Q)^T$.

  换句话说, $bold(A)$ 有一组标准正交的特征向量基. 也即, 对称矩阵完全可以由它的特征值和一组正交特征方向来描述.
]

换个角度理解, 也可以说实对称矩阵从另一个坐标系看, 每个方向相互独立. 即可以完全分解去看. 我们下面介绍的就是"分解"的视角.

核心思想是:

$
  "观测数据"="主要结构"+"异常污染"
$

我们希望把这两者分开, 其实也可以理解成一种去噪的过程. 这就要求我们能让主要结构足够简单, 且异常污染足够零散, 二者对比明显, 则去除污染更为简单.

#v(50pt)

// = SVD (奇异值分解)

// 谱定理主要讲的是*对称矩阵*的正交对角化, 针对一般矩阵我们需要使用SVD.

// 对于任意矩阵$ D1 in RR^(m times n) $

// 都可以写成$ D1=bold(U)bold(inline(sum)) bold(V)^T $

// 其中, $U1 in RR^(m times m)$ 是正交矩阵, $V1 in RR^(n times n)$ 是正交矩阵, $S1 in RR^(m times n)$ 是对角矩阵.

// $
//   S1=mat(sigma_1, 0, ..., 0; 0, sigma_2, ..., 0; dots.v, dots.v, dots.down, dots.v; 0, 0, ..., sigma_p),quad p=min(m, n)
// $

// 并且 $ sigma_1>=sigma_2>=...>=sigma_p>=0 $

// 也可以写成$ D1=sum_(i=1)^p sigma_i u_i v_i^T $

// 其中, $u_i$ 是 $U1$ 的第 $i$ 列, $v_i$ 是 $V1$ 的第 $i$ 列.

// 一个矩阵是若干个rank-1矩阵 $sigma_i u_i v_i^T$ 的和.

// = 经典PCA方法
// #let X1 = $bold(X)$
// 约定: 本文中数据矩阵 $X1 in RR^(n times d)$ 都认为是 $n$ 行样本, $d$ 列特征.

// 设有很多样本, 每个样本是一个列向量, 把它们按列堆成矩阵:$ D in RR^(m times n) $


// 这里的 $r$ 表示允许保留多少个方向.

// 这是一个受约束的全局最小优化问题. 即在所有 $"rank"(A1)<=r$ 的矩阵里, 找距离 $D1$ 最近的那个. 不一定说它必须要接近0.

// 其中, 下标 $F$ 表示Frobenius范数. 其定义为$ ||D1-A1||_F^2=sum_(i,j) (D1_(i j)-A1_(i j))^2 $

// 所有样本点到其重构点的欧氏距离平方和最小.

// == PCA与SVD的关系

// 设一个单位方向向量 $w in RR^d$, $||w||=1$. 把所有样本投影到这个方向上, 得到$ z=X1 w in RR^n $

// 这里 $z_i$ 就是第 $i$ 个样本在方向 $w$ 上的坐标.

// 因为 $X1$ 已经中心化, 所以这个投影后的方差就是:$ "Var"(z)=1/n ||X1 w||^2 $

// 展开:$ ||X1 w||^2=(X1 w)^T (X1 w)=w^T X1^T X1 w $

// 所以我们要解的问题是:$ max_(||w||=1) w^T X1^T X1 w $

// 同样可以使用Lagrange乘子法求解. 结论是, 在单位向量里, 使 $w^T X1^T X1 w$ 最大的 $w$, 就是 $X1^T X1$ 的最大特征值对应的特征向量. 这就是*第一主方向*.

// 下面的问题和谱定理推导就很类似了. 然后第二主方向要求和第一主方向正交, 再让方差最大, 得到第二大特征值对应的特征向量.

// 因为$ w^T X1^T X1 w=||X1 w||^2 $这个量表示数据沿 $w$ 投影后, 总共拉开了多少. PCA就是在找那个让投影最分散, 方差最大的方向. 而 $X1^T X1$ 恰好就是"沿各方向的伸缩强度"编码器来的矩阵.

// #let X1 = $bold(X)$
// 协方差矩阵可以写成 $ S=1/n X1^T X1 quad"或"quad 1/(n-1)X1^T X1 $

// 那么PCA主方向就是 $S$ 的前 $r$ 个特征向量. $S$ 和 $X1^T X1$ 只差一个常数, 所以特征向量完全一样.

// 假设数据矩阵 $X1$ 已经中心化.

// PCA找的主方向实际上就是 $X1^T X1$ 的前 $r$ 个特征向量, 也就是SVD里 $V1$ 的前 $r$ 列. 如果 $X1=U1 S1 V1^T$, 那么 $X1^T X1=V1 S1^T S1 V1^T$. 所以 $X1^T X1$ 的特征向量就是 $V1$ 的列, 特征值就是 $sigma_i^2$.

// == PCA最优解与SVD的关系

// 如果$ D1=U1 S1 V1^T=sum_(i=1)^p sigma_i u_i v_i^T $

// 那么 $rank<=r$ 的最优近似就是保留前 $r$ 项:$ A1_r=sum_(i=1)^r sigma_i u_i v_i^T $

// 也就是$ A1_r=U1_r inline(sum_r)V1_r^T $

// 这就是截断SVD.

// #theorem[Eckart-Young定理

//   $
//     min_(rank(A1)<=r) ||D1-A1||_F^2=sum_(i=r+1)^p sigma_i^2
//   $
//   前 $r$ 个奇异值对应的方向保留下来, 后面都丢掉, 丢掉的信息量正好就是后面奇异值平方和.

//   如果后面的奇异值很小, 说明数据本来就接近低维, 压缩误差小. 如果后面的奇异值不小, 说明压缩会损失很多信息.
// ]

// == 与谱定理的联系

// 虽然 $D1$ 不是对称矩阵, 但 $D1^T D1$ 和 $D1 D1^T$ 一定是*对称半正定*矩阵.

// #proof[
//   $(D1^T D1)^T=D1^T D1$ 满足对称性. 同理, $D1 D1^T$ 也满足对称性.

//   要证明一个实对称矩阵 $bold(M)$ 半正定, 只要证明$ x^T bold(M)x>=0,quad forall x $

//   对 $D1^T D1$, $x^T D1^T D1 x=(D1 x)^T (D1 x)=||D1 x||^2>=0$

//   所以 $D1^T D1$ 半正定. 同理 $D1 D1^T$ 也半正定.
// ]

// 可以用谱定理.

// *对 $D1^T D1$ 做谱分解*
// #let L1 = $bold(Lambda)$
// #let diag = $"diag"$
// $
//   D1^T D1=V1 L1 V1^T
// $
// 其中, $V1$ 是正交矩阵, $L1=diag(lambda_1, ..., lambda_n)$, $lambda_i>=0$

// 一个方向 $x$ 被 $D1$ 作用后, 长度平方变成多少? 因为 $x^T D1^T D1 x=||D1 x||^2$

// 长度平方不可能是负的, 所以它一定半正定.

// 设 $v_i$ 是 $D1^T D1$ 的特征向量, 对应特征值 $lambda_i$:$ D1^T D1 v_i=lambda_i v_i $如果 $||v_i||=1$, 那么$ ||D1 v_i||^2=(D1 v_i)^T (D1 v_i)=v_i^T D1^T D1 v_i=v_i^T (lambda_i v_i)=lambda_i $

// 所以 $||D1 v_i||=sqrt(lambda_i)$. 这说明 $v_i$ 是输入空间里的一个特殊方向, $D1$ 把这个方向上的单位向量 $v_i$ 映射到某个向量 $D1 v_i$, 这个向量的长度是 $sqrt(lambda_i)$.


// 定义$ sigma_i=sqrt(lambda_i) $为奇异值.

// 奇异值 $sigma_i$ 表示矩阵 $D1$ 在某个特殊方向 $v_i$ 上, 把长度放大了多少倍. $D1^T D1$ 记录的是这个放大量的平方, 所以它的特征值是 $sigma_i^2$.

// *构造左奇异向量*

// 对每个$sigma_i >0$, 定义$ u_i=1/sigma_i D1 v_i $就可以得到 $U1$ 中的列向量.

// 于是最后得到$ D1=U1 S1 V1^T $

// 这就是 SVD.

// #thinking[
//   SVD可以看成谱定理对一般矩阵的推广. 谱定理可以处理对称矩阵 $bold(M)=bold(Q Lambda Q)^T$, 而 SVD可以处理任意矩阵 $D1=U1 S1 V1^T$. 如果 $D1$ 恰好是对称矩阵, 那么SVD和特征值分解是非常相近的.

//   例如若 $D1=bold(Q Lambda Q)^T$, 那么SVD里奇异值是$ sigma_i=abs(lambda_i) $所以SVD可以理解成更为一般的工具.
// ]

= 从PCA到SVD

== 约定

设中心化后的数据矩阵为 $ X1 in RR^(n times d) $

其中每一行是一个样本, 每一列是一个特征. 若 $aw in RR^d$ 是一个方向, 则样本在该方向上的投影为$ arrow(z)=X1 aw in RR^n $

第 $i$ 个样本的投影值就是 $z_i = x_i^T aw$.

== 回顾

下面是另一篇文章"谱定理的最优化推导"的思想总结.

=== 谱定理的最优化思想



对称矩阵 $A1=A1^T$ 的最大特征值与特征向量, 可由下面的问题得到$ max_(||x||=1)x^T A1 x $最大值就是 $A1$ 的最大特征值, 取到最大值的单位向量就是对应特征向量.

再在其正交补上继续做, 就能依次得到全部特征值和一组特征向量.

谱定理告诉我们, "找最能放大二次型的方向", 实际上就是找特征向量. 这是PCA的核心思想.

== 数据引导的耦合度

在前面推谱定理的时候, 我们定义了耦合度$ B(ax,ay)=ax^T A1 ay $

== PCA

#let az = $arrow(z)$
=== 主要思想

经典PCA方法的任务是, 在所有*低维*子空间里, 找一个*最能代表这些数据的子空间*. 也即, 找一个低秩矩阵 $bold(A)$, 使得它尽可能接近 $bold(D)$, 近似求解$ min_bold(A) ||bold(D)-bold(A)||_F^2quad"s.t." "rank"(bold(A))<=r $

#thinking[当数据已经中心化时, 寻找最优的低维子空间, 也可以等价地表述为: 把数据投影到某个低维子空间后, 使投影所保留的信息尽可能多.

  或者说, 使由投影带来的重构误差尽可能小.

  进一步地, 等价于让投影后的数据方差尽可能大.]

这与谱定理是类似的, 只不过这里是找"方差最大"的方向.

=== 问题定义

取一个单位方向 $aw in RR^d,quad ||aw||=1$, 把数据投影到 $aw$ 上:$ az =X1 aw in RR^n $

由于数据已经中心化, 所以投影后的均值也是0:$ 1/n sum_(i=1)^n z_i=1/n sum_(i=1)^n x_i^T aw=(1/n sum_(i=1)^n x_i)^T dot aw=0 $

投影后的总方差就是$ "Var"(az) & =1/n sum_(i=1)^n z_i^2 \
          & =1/n||X1 aw||^2 \
          & =1/n (X1 aw)^T (X1 aw) \
          & =1/n aw^T X1^T X1 aw $


// PCA找主方向就是要找 $ max_(||aw||=1) aw^T X1^T X1 aw $

当然如果用样本方差, 就要修正为 $1/(n-1)$. 不过无论是 $1/n$ 还是 $1/(n-1)$, 都不会影响最优方向. 第一主方向就是解$ max_(||aw||=1)aw^T X1^T X1 aw $

// 也将其构造为Lagrange乘子, 求得发现第一主方向是 $X1^T X1$ 的最大特征值对应的特征向量.

// 再要求第二个方向与第一个正交, 并使方差最大, 就能得到第二特征向量, 以此类推.

// PCA的前 $r$ 个主方向, 就是 $X1^T X1$ 的前 $r$ 个特征向量.

#thinking[
  前面定义的耦合度在这里具体化为$ B_X1 (ax,ay)=ax^T X1^T X1 ay=(X1 ax)^T (X1 ay) $

  它表示数据在方向 $ax,ay$ 上的投影之间的二阶耦合. 特别地, 当 $ax=ay=aw$ 时$ B_X1 (aw,aw)=aw^T X1^T X1 aw=||X1 aw||^2 $

  这就是数据沿方向 $aw$ 的投影能量, 也就是所有样本在该方向上投影平方和的总量.

  PCA就是在单位向量中寻找能使投影能量 (投影方差) 最大的方向$ max_(||aw||=1) aw^T X1^T X1 aw $
]

=== 问题求解与验证指标
不难证明, $X1^T X1$ 是对称实矩阵. 我们可以用谱定理的思想.

由谱定理可知, 这个最优方向其实就是 $X1^T X1$ 的最大化特征值对应的特征向量. 继续在正交约束下优化, 还可以得到其余主方向.
#let aq = $arrow(q)$
若$ X1^T X1 arrow(q)_i=lambda_i arrow(q)_i,quad||arrow(q)_i||=1 $
则第 $i$ 个主方向 $arrow(q)_i$ 上的投影能量就是$ ||X1 arrow(q)_i||_2^2=lambda_i $

投影方差自然就是 $lambda_i/n$.

另一方面, 总能量可以表示为$ ||X1||_F^2=sum_(i=1)^d lambda_i $

总方差为$ 1/n ||X1||_F^2=1/n sum_(i=1)^d lambda_i $

由此可以定义第 $i$ 个主成分的能量贡献率. 其实就是方差贡献率了:$ lambda_i/(sum_j lambda_j) $

前 $k$ 个主成分的累计贡献率可以表示为$ (sum_(i=1)^k lambda_i)/(sum_j lambda_j) $

#thinking[
  特征值越大, 说明该方向上聚集的能量越多 (解释的方差越大), 因此它越能代表数据的主要变化; 特征值较小的方向往往只携带变化或噪声.

  在实际应用中, PCA常用于降维, 压缩, 去噪. 保留贡献率高的前几个主方向, 舍弃其他方向.
]

== SVD分解

#let av = $arrow(v)$
#let au = $arrow(u)$
PCA已经说明了, 大的特征值对应大的能量 (大的方差贡献). $X1^T X1$ 的特征向量 $aq_i$ 给出了最重要的方向.

#thinking[$aq_i$ 或许也可以描述 $X1$ 本身, 把 $X1$ 拆开.]

设 $aq_i$ 是 $X1^T X1$ 的单位特征向量, 即$ X1^T X1 aq_i=lambda_i aq_i,quad ||aq_i||=1 $

左乘 $aq_i^T$ 恰好得到标量, 同时看 $X1$ 作用在 $q_i$ 上得到的向量 $X1 aq_i$, 它的长度满足$ ||X1 aq_i||^2=aq_i^T X1^T X1 aq_i=aq_i^T (lambda_i aq_i)=lambda_i>=0 $

// 因此, 当 $lambda_i>0$ 时, 向量 $X1 aq_i$ 的长度为$ ||X1 aq_i||=sqrt(lambda_i) $

这说明, $X1^T X1$ 一定是半正定的, 并且我们还发现, 奇异值按定义它就是非负数.

当 $X1$ 作用在主方向 $aq_i$ 上时, 会把它送到某个新方向, 并放大 $sqrt(lambda_i)$ 倍. 我们把放大倍数记作:$ sigma_i=sqrt(lambda_i) $
#let ap = $arrow(p)$

新方向可以定义为 $X1 aq_i$ 单位向量:$ ap_i=(X1 aq_i)/(||X1 aq_i||)=(X1 aq_i)/sigma_i\ \ X1 aq_i=sigma_i ap_i $

接着, 由$ X1^T X1 aq_i=lambda_i aq_i=sigma_i^2 aq_i $

// 可得

// 对于每个满足 $lambda_i>0$ 的主方向 $aq_i$, 记$ sigma_i=sqrt(lambda_i),quad ap_i=(X1 aq_i)/sigma_i $

// 由于$ ||X1 aq_i||^2=lambda_i=sigma^2_i $

// 所以 $ap_i$ 是单位向量, 且满足$ X1 aq_i=sigma_i ap_i $

// 由$ X1^T X1 aq_i=lambda_i aq_i=sigma_i^2 aq_i $

可得$ X1^T ap_i=X1^T (X1 aq_i)/sigma_i=(X1^T X1 aq_i)/sigma_i=sigma_i aq_i $

于是我们得到一对对关系:$ X1 aq_i=sigma_i p_i,quad X1^T ap_i=sigma_i aq_i $

如果把这些向量排成矩阵$ bold(P)=mat(ap_1, ..., ap_r),quad bold(Q)=mat(aq_1, ..., aq_r) $
就有$ X1 bold(Q)=bold(P)bold(inline(sum)) $

从而$ X1=bold(P inline(sum) Q)^T $

这里, $bold(Q)$ 的列向量是 $X1^T X1$ 的标准正交特征向量, 也即$ bold(Q)^T bold(Q)=bold(I) $

$bold(P)$ 的列向量 $ap_i$ 也两两正交, 因为$ ap_i^T ap_j & =((X1 aq_i)^T (X1 aq_j))/(sigma_i sigma_j) \
            & =(aq_i^T X1^T X1 aq_j)/(sigma_i sigma_j) \
            & =(lambda_j aq_i^T aq_j)/(sigma_i sigma_j) \
            & =delta_(i j)=cases(0\,i!=j, 1\,i=j) $

所以, $bold(P)$, $bold(Q)$ 都是列正交矩阵, $S1$ 是非负对角矩阵, 因此 $X1=bold(P inline(sum) Q)^T$ 正是 $X1$ 的奇异值分解.

换成标准记号就可以得到SVD分解式:$ X1=bold(U inline(sum) V)^T $

SVD可以看作是对PCA结构的一种更完整的矩阵表达.

= Robust PCA@wright2009robust

== 经典PCA的问题

前面也看了, PCA本质就是找低秩结构, 在所有低维子空间里, 找一个最能代表这些数据的子空间. 并且我们发现它和谱定理是连起来的, 我们在做PCA时自然会问到"哪个方向最重要", 遇到这个问题时, 自然而然会转到谱定理, 进而转到SVD.

经典PCA对于高斯型, 小幅但广泛存在的噪声是可以正常工作的. 但是出现少量幅值很大的异常污染时, 方差会被离群点主导, PCA主方向就会严重偏移.

Robust PCA 正是针对这种"大但稀疏"的污染模型提出的.

#let outliers = ((0, 5), (0, -5))
#import cetz.draw

#let normal = (
  (-3, 0),
  (-2, 0),
  (-1, 0),
  (1, 0),
  (2, 0),
  (3, 0),
)

#let outliers = ((0, 5), (0, -5))
#figure(caption: [蓝点表示主体数据, 红点表示离群点.], grid(
  columns: 2,
  gutter: 1cm,

  [

    #cetz.canvas(length: 0.7cm, {
      // 坐标轴
      draw.line((-4.5, 0), (4.5, 0), stroke: gray + 0.5pt)
      draw.line((0, -6), (0, 6), stroke: gray + 0.5pt)

      // PCA 主方向：沿 x 轴
      draw.line((0, 0), (4.2, 0), stroke: rgb("#2563eb") + 2.5pt, mark: (end: ">"))
      draw.content((3.8, 0.7), [PCA主方向], anchor: "south")

      // 正常点
      for p in normal {
        draw.circle(p, radius: 0.12, fill: rgb("#2563eb"), stroke: none)
      }

      // 轴标签
      draw.content((4.8, -0.4), [$x$])
      draw.content((0.5, 5.6), [$y$])
    })

    #align(center)[
      数据主体沿 $x$ 轴分布, PCA 正确识别主方向.
    ]
  ],

  [

    #cetz.canvas(length: 0.7cm, {
      // 坐标轴
      draw.line((-4.5, 0), (4.5, 0), stroke: gray + 0.5pt)
      draw.line((0, -6), (0, 6), stroke: gray + 0.5pt)

      // 原本的理想主方向（灰色虚线）
      draw.line((0, 0), (4, 0), stroke: (gray + 1.2pt))

      // 被拉偏的 PCA 主方向：沿 y 轴
      draw.line((0, 0), (0, 5.5), stroke: rgb("#dc2626") + 2.5pt, mark: (end: ">"))
      draw.content((0.9, 5.2), [PCA主方向], anchor: "west")

      // 正常点
      for p in normal {
        draw.circle(p, radius: 0.12, fill: rgb("#2563eb"), stroke: none)
      }

      // 离群点
      for p in outliers {
        draw.circle(p, radius: 0.14, fill: rgb("#dc2626"), stroke: none)
      }

      // 轴标签
      draw.content((4.8, -0.4), [$x$])
      draw.content((0.5, 5.6), [$y$])
    })

    #align(center)[
      离群点主导方差, PCA 主方向被拉偏至 $y$ 轴.
    ]
  ],
))

== Robust PCA 的基础思想

#let E1 = $bold(E)$

这篇文章指出, 与其把全部数据都硬塞进一个低秩模型, 不如直接承认数据里有两部分:$ D1=A1+E1 $

- $A1$ 是真正想恢复的低秩结构.

  #thinking[
    秩衡量的是矩阵的"信息复杂度". 秩越小, 说明 $A1$ 的行或列之间的线性相关性越强, 结构越简单.

    Robust PCA 假设真实数据 $A1$ 应该具有此低秩结构.
  ]

- $E1$ 是污染项, 它可以数值很大, 但只出现在少量位置上. 所以它是稀疏的.

#definition[理想Robust PCA模型

  $
    min_(A1,E1) underbrace(rank(A1), "低秩项")+gamma underbrace(||E1||_0, "稀疏项") quad "s.t."quad A1+E1=D1
  $]

其中, $rank(A1)$ 想让 $A1$ 尽可能低秩, $||E1||_0$ 统计 $E1$ 里有多少个*非零元素*, 想让污染尽量稀疏.

参数 $gamma$ 是平衡两项的权重, $gamma$ 越大, 说明对 $E1$ 的非零惩罚越重, 模型更不愿意把数据解释为异常项 $E1$. $gamma$ 越小, 更容易把偏离归入 $E1$.

$||E1||_0$ 记作 $cal(l)_0$, 它数矩阵 $E1$ 中非零元素的个数, 这个值越小, $E1$ 越稀疏.

#thinking[
  模型假设噪声 $E1$ 是稀疏且任意大的. 它只少数位置有非零值, 但这些非零值可以*非常大* (比如传感器突然坏了, 读数很大). 这就是Robust的来源, 传统PCA会把大噪声的能量分散到整个矩阵, 扭曲主方向.
]

这是个理想模型, 它刻画出我们想要的分解. 找一个尽可能简单的低秩矩阵 $A1$, 加上一个尽可能稀疏的噪声矩阵 $E1$, 恰好等于观测数据 $D1$.

但是问题在于, 这个优化问题本身是NP-hard的. $rank(dot)$ 不是凸的, $||dot||_0$ 也不是凸的. 难以找到全局最优解.

== "简单" 与 "零散" 的刻画

上面最理想的模型$ min_(A1,E1)rank(A)+gamma||E1||_0quad "s.t."quad A1+E1=D1 $

== "零散"的刻画

=== 理想的计数函数

若一个数 $t$ 表示某个坐标的取值, 那么这个坐标有没有被使用应该只与 $t$ 是否为0有关. 因此, 最简单的 $cal(l)_0$ 范数可以定义为一个最理想的计数函数:$ Phi_0(t)=cases(0\,quad t=0, 1\,quad t!=0) $

只要这个坐标非零, 就记1分. 但是这个函数问题很明显: 它在 $t=0$ 附近是跳跃的, 不具有连续性. 同时也不是凸函数.

=== 具备凸替代的函数

#figure(caption: [$x^0.1$ 到 $abs(x^3)$ 的可视化], image("funcs.svg", width: 80%))

先考虑 $t in [-1,1]$, 则 $|t|$ 是一个凸函数, 且满足$ abs(t)<=Phi_0 (t),quad forall t in[-1,1] $

更进一步, 任意满足 $g(t) <= Phi_0 (t)$ 的凸函数 $g$, 都有$ g(t)<=abs(t),quad forall t in [-1,1] $

此外, $abs(t)$ 可以看成 $Phi_0$ 在 $[-1,1]$ 上最大的凸下界.

// #thinking[
//   凸函数的定义式: 设 $x$ 在左, $y$ 在右, $lambda in [0,1]$, 凸函数的定义是$ f(x+lambda(y-x))<=f(x)+lambda(f(y)-f(x)) $]

#proof[
  *先证 $abs(t)<=Phi_0 (t)$*.

  - 当 $t=0$ 时, $abs(t)=0=Phi_0 (t)$

  - 当 $t!=0$ 时, 因为 $t in [-1,1]$, 所以 $abs(t)<=1=Phi_0 (t)$.

  所以$ abs(t)<=Phi_0 (t) $

  *再证任意凸函数 $g<=Phi_0$ 都满足 $g<=abs(t)$*.


  - 对 $t in [0,1]$, 把它看成从0出发, 向1走 $t$ 比例步长到达的点:$ t=0+t(1-0) $由凸函数定义$ f(x+lambda(y-x))<=f(x)+lambda(f(y)-f(x)) $代入 $x=0,y=1,lambda=t$, 得$ g(t)=g(0+t(1-0))<=g(0)+t(g(1)-g(0)) $

    又因为 $g<=Phi_0$, 所以$ g(0)<=Phi_0 (0)=0,quad g(1)<=Phi_0 (1)=1 $

    因此$ g(t)<=(1-t)dot 0+t dot 1=t=abs(t) $

  - 对$t in [-1,0]$, 把它看成从0出发, 向 -1 走 $abs(t)$ 比例步长到达的点 (此时 $abs(t)=-t in [0,1]$): $ t=0+abs(t)(-1-0) $由凸性, 这里 $x=0,y=-1,lambda=abs(t)$, 得$ g(t)=g(0+abs(t)(-1-0)<=g(0)+abs(t)(g(-1)-g(0)) $

    代入 $g(0)<=0$ 与 $g(-1)<=Phi_0 (-1)=1$, 得

    $ g(t)<=(1-abs(t))g(0)+abs(t)g(-1)=abs(t) $

  综上, $g(t)<=abs(t),quad forall t in [-1,1]$.
]

#thinking[
  在一维里, 是否非零这个跳跃计数函数, 一旦要求凸, 最自然剩下来的就是 $abs(t)$.
]

=== 一维推广到向量

#figure(caption: [放在一起看], cetz.canvas(length: 3cm, {
  import draw: *

  // 坐标轴
  line((-1.3, 0), (1.3, 0), mark: (end: ">"))
  line((0, -0.3), (0, 1.3), mark: (end: ">"))
  content((1.35, -0.1), $t$)
  content((-0.1, 1.35), $y$)

  // x 轴刻度 -1, 1
  for x in (-1, 1) {
    line((x, -0.05), (x, 0.05), stroke: black + 0.5pt)
    content((x, -0.18), $#x$)
  }
  // y 轴刻度 0, 1
  for y in (0, 1) {
    line((-0.05, y), (0.05, y), stroke: black + 0.5pt)
    content((-0.15, y), $#y$)
  }

  // |t|：V 字形
  line((-1, 1), (0, 0), stroke: blue + 1.2pt)
  line((0, 0), (1, 1), stroke: blue + 1.2pt)
  content((1.15, 1.05), text(blue)[$|t|$])

  // Phi_0(t)：t!=0 时为 1，t=0 时为 0
  line((-1, 1), (0, 1), stroke: red + 1.2pt)
  line((0, 1), (1, 1), stroke: red + 1.2pt)
  // (0,1) 空心圆，表示 t=0 处不取 1
  circle((0, 1), radius: 0.04, fill: white, stroke: red + 1pt)
  // (0,0) 实心圆，表示 t=0 处函数值为 0
  circle((0, 0), radius: 0.04, fill: red, stroke: red + 1pt)
  content((0.5, 1.15), text(red)[$Phi_0(t)$])
}))

$cal(l)_1$ 实际上就是在做逐坐标计数的凸化.

对向量 $ax=(x_1,...,x_n)^T$, 定义$ ||ax||_0=\#{i:x_i!=0} $

它正是在数有多少个坐标被使用.

另一方面, $ ||x||_1=sum_(i=1)^n abs(x_i) $

若把每个坐标都限制在 $[-1,1]$, 即 $||x||_oo <=1$, 那么由一维结果逐坐标相加可知$ ||ax||_1<=||ax||_0 $

// 因为对每个坐标都有$ abs(x_i)<=cases(0\,quad x_i=0, 1\,quad x_i!=0) $所以求和得到$ sum_i abs(x_i)<=sum_i bold(1)_{x_i!=0}=||ax||_0 $

// 这说明在有界盒子 $||x||_oo <=1$ 上, $||ax||_0$ 是精确计数, 而 $||ax||_1$ 是"凸化后的线性计数".

=== $cal(l)_1$ 的优化意义

#thinking[从直觉上来看, $||ax||_0$ 在数激活了多少坐标, 而 $||ax||_1$ 其实是给激活的坐标收费.

  由于我们的总体目标是最小化 $||ax||_0$, 替换为 $||ax||_1$, 则在最小化的过程中会倾向于"能关的开关都关掉", "只保留少量真正必要的坐标".

  从这里看, $cal(l)_1$ 不仅满足了凸性, 也促进了稀疏性.]

下面我们就证明, $cal(l)_1$ 不仅是自然的凸替代, 更能帮助产生稀疏.

==== Subgradient (次梯度)

介绍下前置知识. 考虑上面的 $f(x)=abs(x)$, 这是凸函数.

但是它在 $x=0$ 处是不可微的, 因为它没有导数.

// 次梯度就是为了在没有导数的情况下, 判断 $x=0$ 是不是最小值的工具.

*几何来源*. 对于可微凸函数, 在最小值点 $x^*$ 处, 切线是水平的:$ f(y)>=f(x^*)+nabla f(x^*)^T (y-x^*) $

其中, $nabla f(x^*)=0$.

凸函数 $f$ 在点 $x$ 处的次梯度 $g$ 满足:$ f(x+Delta x)>=f(x)+g^T Delta x,quad forall Delta x $

$g$ 的所有可取的值构成的集合构成次微分 $partial f(x)$. 次微分是所有次梯度的集合.

*最优性条件*. $x^*$ 是全局最小值点 $<=>0 in partial f(x^*)$. 存在某个次梯度 $g in partial f(x^*)$, 使得 $g=0$.

#example[
  起点 $x^*=0$, $f(x)=abs(x)$. 要 $g in partial abs(0)$, 即 $ abs(0+Delta x)>=abs(0)+g dot Delta x,quad forall Delta x $

  可以简化为$ abs(Delta x)>=g dot Delta x,quad forall Delta x $

  - $Delta x>0$ 时, 不等式变成 $Delta x>=g dot Delta x=>g<=1$

  - $Delta x<0$ 时, 不等式变成 $-Delta x>=g dot Delta x=>g>=-1$

  - $Delta x=0$时, $0>=0$, 无约束.

  综上可求得 $g in [-1,1]$. 0在这其中, 因此这一点是最小值点.
]

其实很好理解, 代 $g=0$ 进去, 也就是 $f(x+Delta x)>=f(x),quad forall Delta x$

不管往哪走, 函数值都变大, 那它的确就是局部最小值了. 又由于它是凸函数, 因此它肯定是全局最小值点了.

*次微分的加法规则* $partial (f+g)supset.eq partial f+partial g$ 在凸函数的情形下是始终成立的. 这本质上是集合的加法规则.

但反方向 $partial (f+g)subset.eq partial f+partial g$ 中, $partial(f+g)$ 中的某个元素可能无法拆成 $partial f$ 和 $partial g$ 中元素的和. 加法成立是需要条件的.

// 等式成立的核心要求是, 次微分信息能干净拆分. 最常见的情形是一个可导 (提供唯一梯度), 另一个任意凸 (提供次微分集合), 两者可以直接相加.

==== Proximal Operator (邻近算子)

介绍下另一个前置知识. 想象有一个优化目标, 每次迭代都向更新参数, 但是*不希望走得太远*. Proximal就是在这个更新过程中引入锚点, 约束新的参数值靠近旧的参数值.

#definition[
  Proximal Operator

  $
    "prox"_(lambda f)(av)=arg min_ax (f(ax)+bold(1/(2lambda) ||ax-av||^2))
  $

  加粗的部分就是Proximal项. 它惩罚 $ax$ 与当前点 $av$ 的距离. $lambda$ 越小, 惩罚越强, $ax$ 越贴近 $av$. 这个一般用于保证解的唯一性和稳定性.
]

#thinking[
  Proximal Operator与Lagrange乘子法有一定关系. $lambda$:$ L=arg min_ax (f(ax)+lambda g) $

  都是通过线性组合一个项达到约束. 但是它们的本质不同.

  Proximal的 $lambda$ 是超参数, 人为设定的, 一般是固定不动的. 而 Lagrange的 $lambda$ 是优化变量, 由算法自动调节.

  在最优时, Proximal的 $lambda$ 可能对解仍然有拉力, 而Lagrange的 $lambda$ 可以收敛到使约束恰好成立的值, 强制约束成立.

  Proximal的约束更接近软约束.
]
==== $cal(l)_1$ 的Proximal更新

给定 $y in RR$, 考虑一维问题$ min_x 1/2 (x-y)^2+tau abs(x),quad tau>0 $

它的唯一解是$ x^star="Soft"_tau (y)=cases(y-tau\,quad &y>tau, 0\,quad& abs(y)<=tau, y+tau\,quad &y< -tau) $

#proof[
  当 $x>0$ 时, 此时 $abs(x)=x$, 目标函数 $ f(x)=1/2 (x-y)^2+tau x $求导$ f'(x)=x-y+tau $令$f'(x)=0$得$x=y-tau$. 同时由于 $x>0$, 还需要 $y>tau$.

  当 $x<0$ 时是同理的, 这里不证.

  当 $x=0$ 时, 检查0是否满足次梯度最优性条件.

  因为$ lr(0 in partial (1/2 (x-y)^2 + tau abs(x)) |)_(x=0)=(-y)+tau[-1,1] $
  这等价于$ y in [-tau,tau] $
  唯一解得证.
]

#corollary[
  对向量问题$ min_ax 1/2 ||ax-ay||_2^2+tau||ax||_1 $

  其解为逐坐标软阈值:$ ax_i^star="Soft"_tau (ay_i) $
]

#thinking[
  软阈值公式还可以写作$ ax_i^star="sgn"(ay_i)(abs(ay_i)-tau)_+ $

  $cal(l)_1$ 有两个明确的动作. 一方面是当 $abs(ay_i)<=tau$ 时, $ax_i^star=0$, 小坐标会直接被删掉. 当 $abs(ay_i)>tau$ 时, 统一减去一个阈值 $tau$.

  实际上 $cal(l)_1$ 的作用可以表示为, 足够小的扔掉, 足够大的保留下来并做一定收缩.

  再如 $cal(l)_2$ 平方正则问题$ min_ax 1/2 ||ax-ay||^2_2+tau/2 ||ax||^2_2 $的解是$ ax^star=1/(1+tau)ay_i $只要原来 $ay_i!=0$, 缩小后通常不为0.

  因此, $cal(l)_2$ 平方正则只会整体缩放, 不会产生坐标级稀疏. 它可以稳住变量, 抑制过大幅度, 降低整体能量. 但是并不偏好把某些坐标变成精确0.
]


到这里, 我们证实了, 稀疏性 $=> ||ax||_0 arrow.r.squiggly ||ax||_1$

== "简单" 的刻画

=== 秩与奇异值的关系

前面我们已经推过SVD:$ X1=U1 S1 V1^T $其中, $S1="diag"(sigma_1,...,sigma_r),sigma_i>0$.

把它展开写成求和的形式就是$ X1=sum_(i=1)^r sigma_i u_i v_i^T $

这里每一项 $u_i v_i^T$ 都是一个秩为1的矩阵.

这个分解可以理解为: 一个矩阵是由若干个正交的秩为1的矩阵叠加而成的. $sigma_i$ 则表示第 $i$ 个矩阵被激活的强度.

由此, 奇异值与矩阵复杂度便建立了联系. 可以很自然地引出下面的定义:

#definition[秩的奇异值表达

  若 $X1$ 的奇异值为 $sigma_1,...,sigma_r$, 则$ rank(X1)=\#{i:sigma_i (X1)!=0} $也即$ rank(X1)=||sigma(X1)||_0 $这里 $sigma(X1)$ 表示由全部奇异值组成的向量.]

#thinking[
  秩就是奇异值向量的 $cal(l)_0$.
]

所以低秩问题, 本质上也是一个稀疏问题. 这次稀疏的是奇异值坐标. 换句话说,

- 向量稀疏, 则少数坐标被激活;

- 低秩矩阵, 则少数奇异矩阵被激活.

=== 秩的凸替代

既然$ rank(X1)=||sigma(X1)||_0 $

我们还重复上一节的逻辑, 自然得到$ ||sigma(X1)||_1=sum_i sigma_i (X1) $ // !!! 大于0吗

这就是核范数.

#definition[核范数

  定义矩阵 $X1$ 的核范数为$ ||X1||_*=sum_i sigma_i (X1) $它实际上就是奇异值向量的 $cal(l)_1$ 范数.]

#thinking[
  类似地, Frobenius范数满足$ ||X||_F^2=sum_i sigma_i (X1)^2 $它对应的是前面提到的 $cal(l)_2$ 型惩罚, 更倾向于把所有奇异值一起缩小, 而非直接砍掉其中一部分.
]

=== 核范数会对奇异值做软阈值

#let Y1 = $bold(Y)$

若 $Y1=U1 S1 V1^T,quad S1="diag"(sigma_1,...,sigma_q)$, 则问题$ min_X1 1/2||X-Y1||_F^2+tau||X1||_* $
的解为$ X1^star=U1(S1-tau bold(I))_+V1^T $
也即每个奇异值更新为$ sigma_i^star=(sigma_i-tau)_+ $

小奇异值会被砍成0, 矩阵秩下降.

对比Frobenius正则, 它只会整体收缩. 考虑$ min_X1 1/2||X1-Y1||_F^2+tau/2 ||X1||_F^2 $

解为$ X1^star=1/(1+tau)Y1 $

若 $Y1$ 的奇异值为 $sigma_i (Y1)$, 则 $ sigma_i (X1^star)=1/(1+tau)sigma_i (Y1) $

矩阵的秩通常不变.

== 论文的核心结论

在合适条件下, 若 $A1_0$ 足够低秩, $E1_0$ 足够稀疏, 低秩结构和稀疏结构之间没有严重重合, 那么求解$ min_(A1,E1)||A1||_*+lambda||E1||_1quad"s.t."quad A1+E1=D1 $
可以以高概率恢复出原来的 $A1_0$ 和 $E1_0$.

- 低秩矩阵本身不能特别稀疏;

- 稀疏噪声不能太集中得过于结构化, 以至于看起来像低秩;

- 对稀疏部分则常假设其支撑是足够分散/随机的.


#v(50pt)

#bibliography("refs.bib", title: [参考文献], style: "gb-7714-2015-numeric")
