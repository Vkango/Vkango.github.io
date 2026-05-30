#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#show: project.with(
  title: "主成分分析 (PCA) 的思考",
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
  base: "theorem",
  titlefmt: strong,
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


// #title[主成分分析 (PCA) 的思考]

就是数据分析和机器学习里经常用的降维方法.

现在每个样本有很多维特征, 但是很多维度其实高度相关, 保留这些特征变量可以得到更全的信息, 但是也会有很多重复的表达.

除此之外, 我们更想进行聚类分析, 把多个样本通过某些特征维度进行汇聚, 进行可视化分析. 这就要求高维数据尽可能地压缩到二维或三维.

换句话说我们想要的是将高维向量, 投影到低维向量进行进一步分析. 此外, 投影到同维度向量可以理解成特征增强.

= 我们想要什么

设中心化后的样本为$ x_1,x_2,...,x_n in RR^d $

数据矩阵可以表示为$ X in RR^(n times d) $

假设每一列都已经减去了均值.

如果我们只允许保留一个方向$w in RR^d$, 且要求$||w||=1$, 那么每个样本在这个方向上的投影就是$ z_i=x_i^T w $

这样, 我们就将一个高维样本压缩成了一个*一维数值*. 以后可以用这个值代表这个向量.

= 求解 $w$

数据已经中心化, 因此投影后的均值也是0. 于是投影后的样本方差就是$ "Var"(z)=1/n sum_(i=1)^n (x_i^T w)^2 $

表示成矩阵形式$ "Var"(z)=1/n ||X w||^2=1/n w^T X^T X w $

定义协方差矩阵$ S=1/n X^T X $

因此$ "Var"(z)=w^T S w $

从直觉上来看, 如果一个方向上的投影几乎都挤在一起, 则表现为方差很小, 这个方向区分样本的能力很多.

如果一个方向上的投影拉的很开, 那么样本在这个方向上差异明显, 更能表达出区分度.

#thinking[
  方差越大 = 信息越多 是启发式的, 并不总是成立. 但是它确实是很多无监督任务里一个很自然, 很有效的准则.
]

= 新的方向

现在选出了一个方向$arrow(w_1)$. 当然可以选第二个方向, 但如果不加限制, 那第二个方向的最优解就还是$arrow(w_1)$, 毕竟这个方向上方差最大, 信息越多.

#thinking[
  如果两个方向几乎平行, 那么它们投影出来的内容就高度重合. 反过来, 如果两个方向几乎正交, 那么它们则几乎不重叠, 能更好地表示二维空间.
]

因此引入正则约束, 即不得重复抓取同一种特征维度.

由此, 我们确定了两种约束, 对于某个方向本身, 它要尽可能使得投影后的变量方差最大化, 能让不同方向样本有明显区分; 对于投影方向之间, 则让它们也正交化, 以不同的维度进行拆解.

= 公式表达

== 必要条件

最优方向必须满足下面的条件.

问题可以定义为$ max_w w^T S w quad "s.t." w^T w=1 $

这是一个带约束的优化问题, 用Lagrange乘子法可以求解. 构造Lagrange函数$ cal(L)(w,lambda)=w^T S w-lambda(w^T w-1) $

求导有$ nabla_w cal(L)=2S w-2lambda w $

令其为0可得$ S w=lambda w $

这恰好是特征方程的形式. 也即, 如果一个方向是PCA的候选最优方向, 那么它必然是协方差矩阵$S$的特征向量.

#definition[
  如果$S w=lambda w$, 说明$w$经过$S$作用后, 方向没有变, 只是被放大或缩小了$lambda$倍.

  而这个$lambda$, 恰好又对应了该方向上的方差大小.
]

因而, 特征向量给出候选方向, 特征值给出这个方向上的方差大小.

== 充分条件

最终答案一定是"取最大特征值对应的特征向量"吗?

协方差矩阵$ S=1/n X^T X $

这里$S$一定是实对称矩阵. 实对称矩阵的重要结论之一就是谱定理.

#theorem[谱定理

  若$S$是实对称矩阵, 则存在一个正交矩阵$Q$, 使得$ S=Q Lambda Q^T $其中$ Lambda="diag"(lambda_1,lambda_2,...,lambda_d) $是对角矩阵, 对角线上$S$]
