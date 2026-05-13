#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#show: project.with(
  title: "从 Lagrange 定理到 PCGrad 多任务优化方法",
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

#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

= 开端

近期在恶补数学建模校赛, 刚刚复习到非线性规划, 对于有约束非线性规划的求解用到了Lagrange定理. 于是重学了一下这里.

本人大二, 数学知识属于不是很强的那种类型, 如有错误欢迎批评指正.

= 理解Lagrange定理的角度

== 问题定义

对于特殊的只有等式约束的非线性规划问题的情形:

$
  & min f(x), \
  & "s.t."cases(g_j (x)=0\,j=1\,2\,...\,q\,, x in RR^n.)
$

== Lagrange定理的理解

目标函数$f(x)$的梯度$nabla f(x)$代表了*函数值增加最快*的方向.

在没有约束的情况下, 当然可以顺着$nabla f$走, 走到$nabla f=arrow(0)$的地方, 这里就是无约束的极值点.

现在有了约束$g(x)=0$, 往哪里走, 必须要在这个约束面上. 不能随便乱走.

在这里, 其实可以把梯度拆解成两份: 把*想走的理想方向*$nabla f$拆分为两个*互相垂直的分量*, 即
$
  nabla f=nabla f_"满足约束" + nabla f_"不满足约束"
$

- 满足约束的分量 (即切向分量), 这里是$nabla f$沿着约束面*切线*方向的投影. 顺着这个方向走, 依然可以留在$g(x)=0$的面上, 且可以让$f(x)$继续变小.

- 不满足约束的分量 (即法向分量). 这是$nabla f$垂直于约束面的投影. 顺着这个方向走, 会脱离$g(x)=0$的面, 导致约束被破坏.

所以问题就会变成, 限制在$g(x)=0$这个面上, 我们只能用*切向分量*来进行优化.

当沿着约束面不断移动, 寻找极值时, 其实就是在这个切向分量的驱动下移动. 显然, 当这个满足约束的分量变成0时, 可以达到一个极值.

则此时有

$
  nabla f=nabla f_"不满足约束"
$

也即, $nabla f$完全垂直于约束面 (这里用$F$表示).

又因为, $nabla g$也垂直于$F$, 因此必定有

$
  nabla f parallel nabla g
$

若平行则可以线性表示, 也即

$
  nabla f=lambda nabla g
$

即满足$nabla f+lambda nabla g=0$.

由此可得Lagrange定理. 设函数$f,g_j(j=1,2,...,q)$在可行点$x^*$的某个邻域$N(x^*,epsilon)$内可微, 向量组$nabla g_j (x^*)$线性无关, 令
$
  L(x,lambda)=f(x)+lambda^T G(x)
$
其中$lambda=[lambda_1,lambda_2,...,lambda_q]^T in RR^q,G(x)=[g_1 (x),...,g_q (x)]^T$


若$x^*$是局部最优解, 则存在实向量$lambda^*=[lambda_1^*,lambda_2^*,...,lambda_q^*]^T in RR^q$, 使得$nabla L(x^*,lambda^*)=0$. 即$ nabla f(x^*)+sum_(j=1)^q lambda_j^* nabla h_j (x^*)=0. $

= 正交分解

线性代数中, 向量可以分解到任意一组基上, 基不一定要求正交.

在这里, "满足约束"和"不满足约束"的子空间*必然是正交的*.

假设当前在约束面$g(x)=0$上的一点$x_0$. 沿着$arrow(v)$走一小步, 则根据泰勒展开, 约束函数$g$的变化量是

$
  g(x_0+v)approx g(x_0)+nabla g(x_0)dot v
$

又因为$g(x_0)=0$, 所以
$
  g(x_0+v)approx nabla g(x_0)dot v
$

把上面定义的基的概念套进来

+ 满足约束的基

  满足约束, 意味着*走完这一步*, $g$的值*不能变*, 还必须是0.

  也即, 必须有$nabla g(x_0)dot v=0$.

  在几何上, 两个向量内积为0, 意味着它们垂直.

  在所有满足$nabla g dot v=0$的向量$v$, 构成了一个子空间, 即切空间.

+ 不满足约束的基

  只要$v$和$nabla g$的内积不为0, $g$的值离开了0, 则破坏了约束.

  则$nabla g$也可以生成子空间, 即法空间.

这两个空间是正交的.

= KKT条件的理解

库恩-塔克条件是确定某点为最优点的*必要条件*. 但仅对于凸规划充要.

#theorem[*KKT条件*

  设$x^*$是非线性规划问题的*局部最优解*, 且$x^*$点的所有*起作用约束*的梯度$nabla g_i (x^*) (i=1,2,...,p)$和$nabla h_j (x^*) (j=1,2,...,q)$是*线性无关的*, 则存在向量
  $
    lambda^*=[lambda_1^*,lambda_2^*,...,lambda_p^*]^T quad"和"quad mu^*=[mu_1^*,mu_2^*,...,mu_n^*]^T
  $

  对带一般约束的非线性规划问题, 可引进拉格朗日函数:
  $
    L(x,lambda,mu)=f(x)+sum_(i=1)^p lambda_i g_i (x)+sum_(j=1)^q mu_j h_j (x)
  $

  其中, $lambda=[lambda_1,lambda_2,...,lambda_p]^T,mu=[mu_1,mu_2,...,mu_q]^T$叫做拉格朗日乘子.

  使得:

  $
    cases(nabla f(x^*)+sum_(i=1)^p lambda_i^* nabla g_i (x^*)+sum_(j=1)^q mu_j^* nabla h_j (x^*)=0\,, lambda_i^* g_i (x^*)=0\,i=1\,2\,...\,p\,, lambda_i^*>=0\,i=1\,2\,...\,p.)
  $

  满足上述条件的点叫做库恩-塔克点.
]

#theorem[*充分条件*

  若$x$满足库恩-塔克条件, 则$x$必为凸规划的局部最优解, 进而为整体最优解.]

点$x^*$本身要满足:

- 等式约束: $h_j (x^*)=0$.

- 不等式约束: $g_i (x^*)<=0$.

也即, *原始可行性*, 必须*逐个满足*, 不能*相互抵消*.

同时, KKT条件给出了梯度平衡:

$
  nabla f(x^*)+sum lambda_i nabla g_i (x^*)+sum mu_j nabla h_j (x^*)=0
$

即在最优点, *目标函数的梯度*被一些约束的*法相方向*的*线性组合*抵消掉了.

// 这里注意: 抵消的是*方向/法向量*, 而不是*约束值*.

因此, $g(x^*)$和$h(x^*)$是"这个点满不满足约束".

$nabla g(x^*),nabla h(x^*)$是"这个约束在这个点附近限制往哪边走". 这个是KKT讨论的.

下面这张图给出了*到达局部最优解时的梯度情况*.

#let c_obj = rgb("#d9485f")  // 目标函数下降方向
#let c_con = rgb("#2563eb")  // 约束梯度
#let c_fea = rgb("#16a34a")  // 可行方向
#let c_eq = rgb("#f59e0b")  // 等式约束曲线
#let c_ina = rgb("#9ca3af")  // 非活跃约束
#let c_fill = rgb("#dcfce7")  // 可行域填充

#figure(caption: [])[
  #align(center, scale(80%)[

    #cetz.canvas(length: 1.5cm, {
      import cetz.draw: *
      content((2.9, 6.4), anchor: "south", [等式约束: 只能沿切向走])
      content((10.6, 6.4), anchor: "south", [不等式约束: 只有活跃约束参与平衡])

      bezier(
        (4.6, 1.4),
        (0, 2),
        (1.0, 6),
        (2.2, 1.8),
        stroke: (paint: c_eq, thickness: 1.2pt),
      )
      content((4.5, 1.85), anchor: "west", [$h(x)=0$])
      // 最优点 x*
      circle((2.1, 3.55), radius: 0.08, fill: black)
      content((2.3, 3.5), anchor: "west", [$x^*$])
      // 切线（可行方向）
      line(
        (0, 3.29),
        (4.00, 3.77),
        stroke: (paint: c_fea, thickness: 0.9pt, dash: (3pt, 2pt)),
      )
      content((4.2, 4), anchor: "west", [切向方向])
      // 沿切线的两个可行方向
      line(
        (2.1, 3.55),
        (1, 3.42),
        stroke: (paint: c_fea, thickness: 1pt),
        mark: (end: ">"),
      )
      line(
        (2.1, 3.55),
        (3.00, 3.66),
        stroke: (paint: c_fea, thickness: 1pt),
        mark: (end: ">"),
      )
      // 目标函数最想下降的方向 -∇f
      line(
        (2.1, 3.55),
        (2.0, 4.55),
        stroke: (paint: c_obj, thickness: 1.3pt),
        mark: (end: ">"),
      )
      content((2.10, 4.60), anchor: "south-east", [$-nabla f(x^*)$])
      // 等式约束梯度 ∇h
      line(
        (2.1, 3.55),
        (2.2, 2.65),
        stroke: (paint: c_con, thickness: 1.3pt),
        mark: (end: ">"),
      )
      content((2, 2.50), anchor: "north-west", [$nabla h(x^*)$])
      content((2.9, 0), anchor: "south", [最优时，下降方向被法向“挡住”])
      // =========================================================
      // 右图：不等式约束，只有活跃约束参与
      // =========================================================
      // 可行域
      rect((8.7, 1.1), (12.6, 4.7), fill: red.transparentize(50%), stroke: none)
      rect((8.7, 2.5), (12.6, 4.7), fill: c_fill, stroke: none)

      // 两条活跃边界
      line(
        (8.7, 1.1),
        (8.7, 4.7),
        stroke: (paint: c_fea, thickness: 1.3pt),
      )
      line(
        (8.7, 4.7),
        (12.6, 4.7),
        stroke: (paint: c_fea, thickness: 1.3pt),
      )
      content((12.65, 4.75), anchor: "west", [$g_2(x)=0$])
      content((8.7, 0.95), anchor: "north", [$g_1(x)=0$])
      // 最优点 x*
      circle((8.7, 4.7), radius: 0.08, fill: black)
      content((8.85, 4.60), anchor: "west", [$x^*$])
      // 一个可行方向（往可行域内部）
      line(
        (8.7, 4.7),
        (9.75, 3.85),
        stroke: (paint: c_fea, thickness: 1pt),
        mark: (end: ">"),
      )
      content((9.85, 3.80), anchor: "west", [可行方向])
      // 最想下降的方向
      line(
        (8.7, 4.7),
        (7.55, 5.85),
        stroke: (paint: c_obj, thickness: 1.4pt),
        mark: (end: ">"),
      )
      content((7.45, 5.90), anchor: "south-east", [$-nabla f(x^*)$])
      // 活跃约束的梯度
      line(
        (8.7, 4.7),
        (7.45, 4.7),
        stroke: (paint: c_con, thickness: 1.25pt),
        mark: (end: ">"),
      )
      content((7.35, 4.70), anchor: "east", [$nabla g_1(x^*)$])
      line(
        (8.7, 4.7),
        (8.7, 5.95),
        stroke: (paint: c_con, thickness: 1.25pt),
        mark: (end: ">"),
      )
      content((8.85, 5.95), anchor: "west", [$nabla g_2(x^*)$])
      // KKT 平衡关系
      // content(
      //   (9.2, 5.30),
      //   anchor: "south-west",
      //   [$-nabla f(x^*) = mu_1 nabla g_1(x^*) + mu_2 nabla g_2(x^*)$],
      // )
      // 非活跃约束：不贴住边界
      bezier(
        (8.7, 2.6),
        (12.6, 2.5),
        (8.7, 1),
        (9.10, 1.1),
        stroke: (paint: purple, thickness: 0.9pt, dash: (3pt, 2pt)),
        fill: c_fill,
      )
      content((11, 2), anchor: "south", [#set text(fill: purple)

        $g_3(x) = 0$: 分界])
      content((10.8, 1.1), anchor: "south", [$g_3(x) > 0$: 违反约束])
      content((10.65, 2.8), anchor: "south", [$g_i (x) < 0$: 非活跃])
      content((10.6, 0), anchor: "south", [只有活跃约束才会提供"反作用力"])
    })

  ])]

对于左图, $nabla f(x^*)+lambda nabla h(x^*)=0$, 即目标函数的梯度与约束函数的梯度共线.

在等式约束$h(x)=0$的情况下, 动点只能在这条橘黄线的曲线上移动. 在曲线上的任何一点, 能够让目标函数$f(x)$继续下降的方向是$-nabla f(x)$.

如果在某一点, $-nabla f(x)$沿着曲线的*切向*还有分量, 则说明动点还可以继续沿着那个曲线走, 使得目标函数更小.

当$-nabla f(x^*)$完全垂直于曲线的切向时, 此时, $-nabla f(x^*)$所有的力量指向曲线的法向量, 即$nabla h(x^*)$的方向.

对于右图, 可以解释KKT条件.

+ *平稳性*条件与*对偶可行性*条件.

  数学公式: $-nabla f(x^*)=sum mu_i nabla g_i (x^*)$且$mu_i>=0$.

  极值点$x^*$处, 目标函数想往$-nabla f(x^*)$方向走, 但是被边界$g_1(x)=0$和$g_2(x)=0$挡住了.

  $-nabla f$必须落在$nabla g_1$和$nabla g_2$构成的锥形区域内, 因此$mu_i$必须$>=0$.

+ 互补松驰性

  $mu_i dot g_i (x^*)=0$

  在图中, $mu_3=0$. 只有活跃约束才会提供反作用力.

+ 可行方向

  绿色区域是可行域, 从$x^*$出发, 指向绿色区域内部的向量就是可行方向.

  在最优点, 任何可行方向都不再是*下降方向*, 即与$-nabla f$的夹角$>90degree$


左图: 可行方向$d$满足$nabla h(x^*)^T d=0$, 表示$d$在切空间里. 而最优时又要求$nabla f(x^*)^T d=0,quad forall d,nabla h(x^*)^T d=0$

只有切向能走, 在最优点, 切向没有下降的一阶趋势, 因此$nabla f$只能落在法向上.

共线比反向包含更多向量. 正好对应等式乘子$mu in RR$, 不等式乘子$lambda >=0$.

可行方向有很多, 但是KKT点不是要求*无可行方向*, 而是*无可行下降方向*.


// == KKT与一阶微分条件的关系

// $
//   min f(x),quad "s.t."quad h_j (x)=0,j=1,...,q
// $

// 设$x^*$是*局部最优点*.

// 如果从$x^*$往某一个小方向$d$走一点, 走到$x^*+t d$, 为了可行, 必须要有$ h_j (x^*+t d)=0 $

// 对$h_j$做一阶泰勒展开:

// $
//   h_j (x^*+t d)=h_j (x^*)+t nabla h_j (x^*)^T d+o(t)
// $

// 因为$h_j (x^*)=0$, 所以要想一阶上仍然留在约束面上, 必须满足
// $
//   nabla h_j (x^*)^T d=0,j=1,...,q
// $

// 也就是说, 可行方向$d$必须落在约束面的切空间内.

// 对于目标函数$ f(x^*+t d)=f(x^*)+t nabla f(x^*)^T d+o(t) $

// 因为$x^*$是局部最优点, 所以沿任何可行方向都不能让$f$一阶下降.

// 对于等式约束, $d$和$-d$都可行, 则有

// $
//   nabla f(x^*)^T d=0
// $

// 对于所有满足$nabla h_j (x^*)^T d=0$的$d$都成立.

// 等价于$nabla f(x^*)$与整个切空间正交.

// 而切空间的正交补, 正好就是约束梯度张成的法空间:$ nabla f(x^*)in "span"{nabla h_1 (x^*),...,nabla h_q (x^*)} $

// 于是存在$mu_j$, 使得$ nabla f(x^*)+sum_(j=1)^q mu_j nabla h_j (x^*)=0 $

// 这是Lagrange乘子条件.

// == 线性无关性



= 迁移

== 原始想法

思考: 迁移到多任务学习.

假设我们把多任务看成*约束条件*下的问题.

目标: 优化模型, 同时适配多任务.

把模型优化时计算的梯度, 也拆分为两部分

$
  nabla f=nabla f_"协同优化"+nabla f_"混乱模式"
$

在这里, 把*混乱*看成*不满足约束*的梯度.

显然, 我们的目标是让导致模型*混乱*的地方的参数尽可能占据较小的更新权重, 甚至*不更新*.

那么我们可以把最小化$nabla f_"混乱模式"$作为优化目标.

当然这个梯度可能是来自多任务的耦合度以及其他的衡量标准等.

一个简单的例子可能是$ nabla f=underbrace(nabla f_"任务A"+nabla f_"任务B", nabla f_"协同优化")+nabla f_"任务间的混乱梯度" $

== 调整想法

上面说的其实还是很抽象, $nabla f_"任务间的混乱梯度"$其实很难算出来. 它是从$nabla f_"任务A"$与$nabla f_"任务B"$之间提取出来的.

不过我还是给想法搜索了一下, 找到了PCGrad@yu2020gradient 这篇文章.

= PCGrad的理解

与原文一样, 这里也以两个任务为例.

设两个任务的损失分别是$L_1 (theta),L_2 (theta)$, 总目标是$ L(theta)=L_1 (theta)+L_2 (theta) $

对应的梯度分别是$g_1 =nabla L_1 (theta), g_2=nabla L_2 (theta)$.

对于普通的多任务学习, 参数的更新方法为$ g=g_1+g_2 $

== 冲突

假设我们准备用方向$d$进行梯度下降法优化, 也即
$
  theta_"new"=theta-eta d
$
其中, $eta>0$是学习率. 现在看任务$j$的损失会怎么变.

做一阶泰勒展开:
$
  L_j (theta-eta d) & approx L_j (theta)-eta nabla L_j (theta)^T d \
                    & =L_j (theta)-eta g_j^T d
$

- 如果$g_j^T d>0$, 那么$L_j$下降.

- 如果$g_j^T d<0$, 那么$L_j$上升.

也就是说, 一个更新方向$d$对任务$j$是不是友好, 就看$g_j^T d$的符号.

现在令$d=g_i$. 如果$g_j^T g_i<0$, 那就说明, 沿着任务$i$的梯度下降方向更新, 会让任务$j$的损失一阶近似上升!


#definition[
  *任务冲突的定义*

  当两个梯度夹角余弦为负, 也就是$g_i^T g_j<0$时, 它们是*冲突梯度*.
]

在几何体现就是, 两个梯度夹角大于$90degree$, 一个任务想往这边改参数, 另一个任务想往反方向改参数.

== 解决方案

现在我们想做的就是, 希望*尽量保留任务$i$的梯度$g_i$, 但是又不希望伤害任务$j$*.

- 不伤害任务$j$的一阶条件是: $g_j^T d>=0$.

- 尽量保留$g_i$的意思是, 让$d$ (这里理解成正式的优化方向) 离$g_i$*尽可能近*.

于是可以写成一个新的优化问题:
$
  min_d 1/2 ||d-g_i||^2quad"s.t."quad g_j^T d>=0
$

从这里来看, PCGrad实际上是把原梯度$g_i$投影到半空间$g_i^T d>=0$上.

- 如果$g_i^T g_j >=0$, 原来的$g_i$已经满足约束, 最优解就是$d=g_i$, 不用改.

- 如果$g_i^T g_j <0$, 原来的$g_i$不能满足约束, 那么*最近的可行点*会落在边界$g_j^T d=0$上. 于是问题变成了

  $
    min_d 1/2 ||d-g_i||^2quad"s.t."quad g_i^T d=0
  $

== 可行点的求解

这个问题恰好可用拉格朗日乘子法求解:

$
  cal(L)(d,lambda)=1/2 ||d-g_i||^2+lambda g_j^T d
$

那么对$d$求导可得:
$
  nabla_d cal(L)=d-g_i+lambda g_j=0
$

因此, $d=g_i-lambda g_j$.

再代入边界条件$g_j^T d=0$, 则$ g_j^T (g_i-lambda g_j)=0 $

可得$ lambda=(g_i^T g_j)/(||g_j||^2) $

因此$ d=g_i-(g_i^T g_j)/(||g_j||^2)g_j $

(其实想复杂了, 如果$g_i dot g_j <0$, 就减去$g_i$在$g_j$方向上的投影即可). 这是符合直觉的:


在论文中的PCGrad公式
$
  g_i^"PC"=g_i-(g_i^T g_j)/(||g_j||^2)g_j
$

如果$g_i^"PC"dot g_j <0$, 就减去$g_i^"PC"$在$g_j$方向上的投影.


= 与正交分解的关系

在这里我们也是把$g_i$分解成两个部分, 一个平行于$g_j$, 一个垂直于$g_j$.

设$g_i=g_i^parallel+g_i^perp$, 其中$g_i^parallel$平行于$g_j$, 所以可以写成$g_i^parallel=a g_j$; 而$g_i^perp$垂直于$g_j$, 所以$g_i^perp^T g_j=0$.

#figure(caption: [简单的可视化])[

  #cetz.canvas(length: 1cm, {
    import cetz.draw: *
    let O = (0, 0)
    let U = (3, 0)
    let V = (-1.2, 2.078)
    let P = (-1.2, 0)
    line(
      P,
      V,
      stroke: (paint: gray.lighten(40%), thickness: 0.8pt, dash: "dashed"),
    )

    line(
      O,
      U,
      stroke: (paint: blue, thickness: 1.5pt),
      mark: (end: ">"),
    )

    line(
      O,
      V,
      stroke: (paint: black, thickness: 1.5pt),
      mark: (end: ">"),
    )

    line(
      O,
      P,
      stroke: (paint: red, thickness: 2pt),
      mark: (end: ">"),
    )

    line(
      P,
      V,
      stroke: (paint: green, thickness: 2pt),
      mark: (end: ">"),
    )

    line(
      (-0.95, 0),
      (-0.95, 0.25),
      (-1.2, 0.25),
      stroke: (paint: gray, thickness: 0.8pt),
    )

    content((3.15, 0), $g_j$, anchor: "west")
    content((-1.25, 2.22), $g_i$, anchor: "south")
    content((-0.6, -0.22), $g_i^parallel$, anchor: "north", fill: white)
    content((-1.42, 1.1), $g_i^perp$, anchor: "east", fill: white)

    circle(O, radius: 0.035, fill: black, stroke: none)
  })]


因此

$
  g_i=a g_j+g_i^perp
$

两边同时和$g_j$做内积, 得到
$
  g_i^T g_j=a||g_j||^2
$

所以
$
  a=(g_i^T g_j)/(||g_j||^2)
$
因此, $g_i$在$g_j$方向上的平行分量是
$
  g_i^parallel=(g_i^T g_j)/(||g_j||^2)g_j
$

垂直分量是
$
  g_i^perp=g_i-(g_i^T g_j)/(||g_j||^2)g_j
$

PCGrad在冲突时就保留了这个垂直分量.

验算

$
  (g_i^"PC")^T g_j=g_i^T g_j-(g_i^T g_j)/(||g_j||^2)||g_j||^2=0
$

正交: 沿$g_i^"PC"$下降时, 对任务$j$的一阶影响约为0, 不互相帮助, 但是也不互相伤害.


#bibliography("refs.bib", title: [引用])
