#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *

#show: project.with(
  title: "深入浅出背包问题",
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


#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

#let raw-radius = 4pt
#let raw-leading = 0.2em

#show raw.where(block: true): it => {
  set par(leading: raw-leading)
  block(
    radius: raw-radius,
    clip: true,
    stroke: luma(220),
    inset: 0pt,
    it,
  )
}


#show raw.line: it => {
  let bg = if calc.rem(it.number, 2) == 1 { luma(250) } else { white }
  box(
    width: 100%,
    fill: bg,
    inset: (x: 0.8em, y: 0.3em),
  )[#grid(columns: (2em, 1fr), gutter: 1em)[#align(right + horizon)[
      #text(fill: luma(140), font: ("Lucida Console", "Source Han Serif"))[#it.number]
    ]][
      #it.body]
  ]
}

#show raw.where(block: false): it => {
  set text(font: ("Lucida Console", "Source Han Serif"))
  box(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
    it.text,
  )
}


// #title[深入浅出背包问题]

// 作者: Vkango, Moonshot Kimi K2.5-Thinking, Google Gemini 3.0 Pro

= 背包问题定义与分类

== 无限背包问题
#let inf = [
  #problem([*问题定义*

    在满足以下约束条件的情况下:

    $ sum_(i=1)^n a_i x_i <=b, x_i in {0,1,2,...}, 1<=i<=n $

    求目标函数$sum_(i=1)^n c_i x_i$的最大值.
  ])]

#inf

#problem[*等价问题*

  设有一个背包, 它的最多称重量是$b$. 目前有$n$种物品, 每种物品都有一个质量$a_i$和一个价值$c_i$. *允许你随便拿这些物品* (每种物品可以拿任意个), *但是只能拿整数个, 不能切割*.

  请问在不超过背包重量限制的前提下, 拿到的物品总价值最大是多少?
]


== 0/1背包问题

#problem[
  其他条件不变, 改成*每个物品只能拿0/1件, 不能多拿*. 要解决的问题仍不变.
]


== 有限背包问题

#problem[其他条件不变, 改成*每个物品最多只能拿$p_i$件, 不能多拿*. 要解决的问题仍不变.
]

=== 直觉解法 (贪心)

贪心也就是始终拿价值最高的. 这对于*可切割*的物品来看是正确的解法. 贪心只考虑了"密度"最优.

但是这里不能把物品切割开, 因此不能使用"密度"的方法, 不然会把"占用空间"这一条件忽略掉.

= DP规律探究

研究一个问题是否能用DP算法求解, 就要看它是否有最优子结构 + 重叠子问题.

#inf

== 最优子结构

在前面我们考虑使用贪心算法时, 只考虑了"价值"最优, 而不能得到最优解的原因就是我们没考虑空间. 这也提示了我们在定义子问题时, 应该考虑空间.

设我们已知*前$i-1$种*物品在*任意容量*下的最优解. 现在需要我们决定, 对于第$n$种物品, 我们应该拿多少件?

我们用$f(i,v)$表示对*前$i$种*物品在*任意容量*$v$下已求得的最优解. 则$f(i,v)$可以表示为:

$ f(i,v)=max{ & f(i-1,v), \
            & f(i-1,v-a_i)+c_i, \
            & f(i-1,v-2*a_(i-1))+2c_i, \
            & ..., \
            & f(i-1,v-j a_i)+j dot c_i } $其中尾部$j$表示$j in [0, p), v-j a_i>=0$, 且$v-(j+1)a_i<0$.

边界情况: $f(i,0)=0, f(0,v)=0,f(i,j)=-oo (forall j<0)$.

我们将其定义为*算法1*.

可以发现, 全局最优解可以由更小背包, 更少物品的局部最优解拼接出来.

上面我们考虑了可以拿无限多个的情况, 这适用于无限背包问题. 如果是0/1背包问题或有限背包问题, 则可以通过修改$p$项的值同样很方便地证明.

#inf

== 重叠子问题

在刚刚讨论最优子结构的问题时, 我们已经得到了前$i$种物品在任意容量$v$下已求得的最优值. 显然, 这些值是可以复用的, 维护一个二维数组将其保存起来即可, 后面直接查表.

因此背包问题满足最优子结构 + 重叠子问题这两个DP的基本思想, 可用DP算法求解.

= 算法1的不足

// #inf

我们用$f(i,v)$表示对*前$i$种*物品在*任意容量*$v$下已求得的最优解. 则$f(i,v)$可以表示为:

$ f(i,v)=max{ & f(i-1,v), \
            & f(i-1,v-a_i)+c_i, \
            & f(i-1,v-2*a_(i-1))+2c_i, \
            & ..., \
            & f(i-1,v-j a_i)+j dot c_i } $其中尾部$j$表示$j in [0, p), v-j a_i>=0$, 且$v-(j+1)a_i<0$. 边界情况: $f(i,0)=0, f(0,v)=0,f(i,j)=-oo (forall j<0)$.

// 但是这个算法存在问题: 重复访问取最大值.

该式可简写 $ f(i,v)=max_(j>=0,j a_i <=v){f(i-1,v-j a_i)+j c_i} $

我们把$j=0$单独拎出来, 有$ f(i,v)=max{f(i-1,v),underbrace(max_(j>=1,j a_i <=v){f(i-1,v-j a_i)+j c_i}, A)} $


对$A$做变量替换. 令$j'=j-1$, 则$j=j'+1$, 代入$A$, 并把固定加上的常数项提到$max$符号的外面

$
  A & =max_(j'>=0,j'a_i<=v){f(i-1,v-(j'+1)a_i)+(j'+1)c_i} \
    & =bold(max_(j'>=0){f(i-1,(v-a_i)-j'a_i)+j'c_i})+c_i
$

括号里的$max$恰好就是$f(i,v-a_i)$的定义!

因此上式可以直接简化为$ A=f(i,v-a_i)+c_i $

把$A$代回原式$ f(i,v)=max{f(i-1,v),f(i,v-a_i)+c_i} $

和原算法相比, 减少了对$j$项的遍历, 复杂度大大降低! 因此我们将最终的递推式定义为这一个*算法2*. 它的核心是*直接用前一行的一个值, 代表大量$max$*.

#problem[*注意*

  表面上, 新方法是从原方法推导而来的, 它理应和原方法一样*既适用于有限背包问题, 又适用于无限背包问题*. 但是实际上*并非如此*. 总结来看是$j$的定义域问题.

  无限背包时, $j$的取值集合是${0,1,2,...}$, 在代换$j'=j-1$之后*仍然是无限集合*, 也就是$oo-1=oo$. 所以$max{...}$恰好等于$f(i,v-a_i)$. 于是整个$j$循环直接被压成了$f(i,v-a_i)+c_i$, 减少了计算量.

  有限背包时, $j$只能取$0,...,p_i$. 这代表代换后$j'$的集合变成了${0,1,2,...,p_(i-1)}$. 这意味着$max{...}$对应的是*最多再放$p_(i-1)$件*的子问题, *原来定义的$f(i,v-a_i)$中, 最大可以放$p_i$件, 但是现在显然不符合定义*.

  因此, $A=f(i,v-a_i)+c_i$不再成立, 我们不能再对原式进行折叠!

  无限背包 $=>$ $j$集合平移后仍不变, 折叠精确. 有限背包 $=>$ $j$集合平移后*少了一个元素*, 折叠漏掉了"已放满$p_i$"的情况. 于是不能再用同一行递推, 换句话说, 折叠失效的本质是"少算一个$j$", 它*不再满足最优子结构*.
]

我们先使用这种方法将无限背包问题求解, 再思考如何求解0/1背包问题.

== 无限背包问题

刚刚我们已经证明, $f(i,v)=max{f(i-1,v), f(i,v-a_i)+c_i}$

同时边界$f(dot,0)=0$, 且$v<0$时取$-oo$. 该问题可以直接求解.

而实际上, 该方法还可以进一步简化成*一维数组*的形式. 这可以有效降低空间复杂度.

根据该递推式, 用二维DP需要维护一个$O(n dot v)$的二维数组. 同时时间复杂度是$O(n dot v)$. (也就是$n$种物品, 每个物品需要遍历$v$个容量状态).

但是实际上因为*每一轮都是之前已知的值*. 我们发现在更新$f(i,v)$前, 始终有$f(i,v)=f(i-1,v)$, 因此可以直接把$i$这个维度删除. 这样递推链仍然成立.

因此我们只需要维护一个一维数组. $max$内的$"dp"[v]$是更新前的值, 也就是$f(i-1,v)$$ "dp"[v]=max{"dp"[v-a_i], "dp"[v]} $

下面讨论有限背包问题的解法.




== 0/1背包问题

已知无限背包的二维DP式

$ f(i,v)=max{f(i-1,v),f(i,v-a_i)+c_i} $

这个公式的核心在于, 当前状态可以依赖于*同一行*的前面状态. 因为我们允许无限选择同一种物品.

但是0/1背包问题不同, 每种物品只能选择0/1件, 这意味着*当前状态 (第$i$行) 只能依赖于上一行 (第$i-1$行) 的状态*, 不能依赖于*同一行*的状态.


#thinking[

  从上面我们可以发现, 容量本身是不受"放了多少件"的影响的. 容量影响的是"还能不能再放"这个问题. 剩余容量与件数上限两个*独立约束*是"还能不能再放"的答案.

  设当前已放$k$件, 第$i$种单件体积$a_i$, 则*剩余容量需求*为

  $ v' = v - k a_i $

  这个 $v'$ *只由容量算术决定*,跟 $k$ 无关;

  但*能不能再拿一件*要同时看:

  + 容量约束: $v' ≥ a_i$

  + 件数约束: $k ≤ p_i − 1$

  两个条件是*逻辑与*, 不是谁派生谁. 例如, 如果$A$类$2$件 (上限$2$件), $B$类$1$件 (上限$2$件) 达到了容量要求, 且$A$类$1$件, $B$类$2$件也达到了容量要求, 在决定$B$还能不能再放时, 只看容量剩余是不够的. 可能再放一件$B$容量仍然满足, 但是件数就不满足了.

  *"容量"是减法算术, "件数"是计数上限; *
  它们*独立存在*, 只是*同时决定*"下一格是否合法".]

0/1背包问题的算法1方程可表示为$ f(i,v)=max{f(i-1,v),f(i-1,v-a_i)+c_i} $

该式始终成立. 如果我们可以证明$f(i-1,v-a_i)+c_i=f(i,v-a_i)+c_i$就可以也像解法2一样求解. 一维数组角度来看, 我们只需要保证计算$"dp"[v]$时, $"dp"[v-a_i]$仍然是$f(i-1,v-a_i)$, 而不是$f(i,v-a_i)$.

#theorem[*逆序更新影响*

  $
    f(i-1,v-a_i) & =f(i,v-a_i) \
                 & <=>v in "Range"(V,V-1,V-2,...,0)
  $
]

证明如下: 我们已知第$i$轮迭代前, $"dp"[v]=f(i-1,v)$, 现在需要证明*只有逆序更新才可保证* $"dp"[v]=f(i,v)$.

- 一方面, 当$v$从大到小时

  $forall u>v$, $"dp"[u]$已经被更新为$f(i,u)$. 且$forall u<=v$, $"dp"[u]$仍然保持为$f(i-1,u)$.

  因为$v-a_i<v$, 所以$"dp"[v-a_j]=f(i-1,v-a_i)$.

  所以$ "dp"[v] & =max{"dp"[v],"dp"[v-a_i]+c_i} \
          & =max{f(i-1,v),f(i-1,v-a_i)+c_i} \
          & =f(i,v) $ 简化的递推式成立.

- 另一方面, 当$v$从小到大时

  计算$"dp"[v]$时, $"dp"[v-a_i]$已经被更新. (严格来说, 更新为相同值也叫做一次更新, 所以这里的没有用"可能更新").

  实际上$ "dp"[v-a_i] & =f(i,v-a_i) \
              & =max{f(i-1,v-a_i),f(i-1,v-2a_i)+c_i} $


  因此

  $
    "dp"[v] & =max{ &   f(i-1,v),f(i,v-a_i)+c_i} \
            & =max{ & f(i-1,v),f(i-1,v-a_i)+c_i, \
            &       &  bold(f(i-1,v-2a_i)+2c_i)}
  $

  这相当于允许取2件第$i$种物品, 并且越往后拿得越多, 直接变成了无限背包问题, 违背了0/1背包约束. 因此只需逆序更新就可以保证.

== 有限背包问题

我们把$j=0$单独拎出来, 有

$
  f(i,v) & =max{f(i-1,v),underbrace(max_(j=1,...p_i){f(i-1,v-j a_i)+j c_i}, B)} \
         & !=max{f(i-1,v),f(i-1,v-a_i)}
$

新算法与原算法不等价的核心是, 在函数$ f(i,v-a_i)=max_(j>0){f(i-1,(v-a_i)-j a_i)+j c_i} $中, $j$的最大值是$p_i$, 而不是$p_(i-1)$.

也就是说$f(i,v-a_i)$包含了放$p_i$件的情况! $f$判断"能不能再拿一件"的标准仅是判断了是否达到了最大容量, 而没有考虑"件数".



因此, 我们需要构造一个新的方法, 在决定能不能再拿一件时, 同时考虑容量和件数.

算法1通过控制循环次数达到了目的, 即每一轮都从头逐个处理容量, 不会被影响, 但是计算复杂度太高.

和求解0/1背包问题相似, 我们也可以通过逆序的方法求解每一个$f(i,v)$. *但是显然, 这样做效率不高*. 因为仍然需要处理每个容量. 即$v-a_i->v-2a_i...$

一个巧妙的方法是将$p_i$件 (最大值) 拆分成二值组合. 例如, 12件可以拆成二进制数来解决.


#theorem[*二进制拆分的完备性*

  当$p_i->+oo$时, 二进制拆分可表示任意整数$j>=0$. $ forall j>=0, exists b_k in {0,1},quad"s.t."quad j=sum_(k=0)^oo b_k dot 2^k $

  在二进制优化中, 通过$m$个捆绑包的$0\/1$选择, 可以表示$0$到$p_i$之间的任意数量. 当$p_i->+oo$时, 可以表示任意非负整数.

  同时, 逆序更新保证了每个捆绑包只被选择一次, 但所有捆绑包的组合可以表示任意数量. 相当于多了$log_2 p_i$件.]

这样, 我们把时间复杂度从$O(n dot V dot p_max)$降到了$O(n dot log_2 p_max dot V dot 1)=O(n dot log p_max dot V)$.

// 因此算法1可以表示为
// $ f(i,v)=max_(k=0,1,...,p_i)F_i (k,v)=max_(k=0)^p_i {f(i-1,v-k a_i)+k c_i} $

// 如果有$ f(i, v−a_i) + c_i = f(i-1,v−a_i) + c_i $

// 那么我们每算一个容量最大价值, 都可以保证它第$i$类没被放. 这样就可以保证最大放置数量可控. 如何实现?

// 答案是使用反向顺序, 即$v = v, v−1, …, 0$. 这是因为$f(i,v-a_i)$取值全看它自己的递推式, 但由于我们此时没有设置比$v$更小的$v-k a_i$位置下的$f(i,v-k a_i)$的值, 故它不会影响取值.



// 不难发现$F_i (k,v)$对$k$单调不减, 即对固定的$(i,v)$恒有$ F_i (0,v)<=F_i (1,v)<=...<=F_i (p_i,v) $

// 写出$F_i (k,v)$的递推式$ F_i (k,v)=max{F_i (k-1,v),F_i (k-1,v-a_i)+c_i}=max{f(i-1,v),f(i-1,v-k a_i)+k c_i},k=1,2,...,p_i; v=v,v-1,v-2,... $


// 其中, 第一项$F_i (k-1,v)$表示*不再放*第$k$件, 保持$k-1$件. 第二项$F_i (k-1,v-a_i)+c_i$表示*放*第$k$件. 可得

// $ F_i (k-1,v-a_i)+c_i=f(i-1,v-a_i-(k-1)a_i)+(k-1+1)c_i=f(i-1,v-k a_i)+k c_i=F_i (k,v)=f(i-1,v) $


// 因此我们证明了
// $ F_i (k,v)=max{F_i (k-1,v),F_i (k-1,v-a_i)+c_i},"   "F_i (k-1,v-a_i)+c_i=F_i (k,v) $


// 算法1的全局最优是$ f(i,v)=max_(k=0,...,p_i)F_i (k,v) $

// 因此$ F_i (p_i,v)=f(i,v) $也就是在第$i$类*最大取*$p_i$个时, 这个值就对应$f(i,v)$. 这个是显然成立的. 由此我们证明了$F$其实就是$f$, 且只在$v$递减时才成立.

== 无限背包问题何有限背包问题之间的关系推导

接下来我们证明, 当$p_min->+oo$时, *有限背包问题$<=>$无限背包问题*, 两种不同的更新策略 (逆序 / 顺序) 会收敛到相同的结果.

设$f_"finite" (i,v,p_i)$表示有限背包的解, $p_i=(p_1,p_2,...,p_n)$表示各物品的数量限制. 用$f_oo (i,v)$表示无限背包问题的解. 并规定$p_min =min{p_1,p_2,...,p_n}$.

实际上我们就是要证明$ lim_(p_min->+oo)f_"finite" (i,v,p)=f_(+oo)(i,v) $即解相同, 同时还需要证明, 二进制优化 + 逆序更新的算法行为会*趋近于正向更新*.

#proof[

  *证数值相等*.

  对于任意固定的物品$i$和容量$v$, 设物品$i$的重量为$a_i$, 价值为$c_i$.

  有限背包问题和无限背包问题都起源于解法1. 我们可以将它们分别表示为

  有限背包问题 (二进制优化) 的解$ f_"finite" (i,v,p_i)=max_(0<=j<=min(p_i, floor(c_i/a_i))){f(i-1,v-j dot a_i)+j dot c_i} $

  无限背包问题的解$ f_oo (i,v)=max_(0<=j<=floor(c_i/a_i)){f(i-1,v-j dot a_i)+j dot c_i} $

  当$p_min ->+oo$时, $forall i=>p_i->+oo$, 因此$ min(p_i, floor(c_i/a_i))=floor(c_i/a_i) $

  我们将其代入, 可得$ lim_(p_min->+oo)f_"finite" (i,v,p_i) & =max_(0<=j<=floor(c_i/a_i)){f(i-1,v-j dot a_i)+j dot c_i} \
                                       & =f_oo (i,v) $

  证毕.

  实际上就是, 当$p_i>floor(c_i/a_i)$时, 数量限制变得冗余. 算法行为完全由容量约束决定.

  // ==== 正向逆向趋近证明

  // 我们知道, 将$p_i$个物品拆分为$m=floor(log_2 p_i)+1$个"捆绑包"之后, 每个捆绑包$k$的大小是$2^k$ (最后一个可能不同). 对每个捆绑包应用逆序更新可以得到$ "dp"[v]=max("dp"[v], "dp"[v-a_k]+c_k) $

  // 无限背包的算法行为是直接使用正序更新, 即$"dp"[v]=max("dp"[v], "dp"[v-a_k]+c_k)$


  // 设$"dp"_"finite"^(p)[v]$表示有限背包算法在数量限制$p$下的结果, 设$"dp"_oo [v]$表示无限背包的结果.

  // 我们刚刚在数值相等部分证明了$forall v,p_i>floor(c_i/a_i)$时, 始终有$ "dp"_"finite"^(p)[v]="dp"_oo [v] $


  // 因为在容量$v$下, 最终只能放$floor(c_1/a_i)$件物品$i$, 当$p_i>floor(c_1/a_i)$时, 数量限制不再起作用.

  // 对任意的$v$, 当$p_"min" >max_i floor(c_i/a_i)$时, 始终有$ "dp"_"finite"^(p)[v]="dp"_oo [v] $


  // 因此$ lim_(p_"min"->+oo)"dp"_"finite"^(p)[v]="dp"_oo [v] $

  证毕.
]
+ 容量是天然的数量限制. 在固定容量$v$下, 任何物品最多只能放$floor(c_1/a_i)$件.

+ 当$p_i>floor(c_1/a_i)$时, 数量限制变得冗余. 算法行为完全由容量约束决定.

+ 二进制优化的完备性.

+ 在复杂度上, 二进制优化的有限背包$O(n dot V dot log p_max)=>O(n dot V)$, 这是因为$log p_max$增长极度缓慢. 逆向方法效率会逐步趋近于正向方法.
/*
= 算法实现

== 无限背包问题

#show raw: set text(font: ("Lucida Console", "Source Han Serif"))

```python
def unbounded_knapsack(values: List[int], weights: List[int], capacity: int) -> int:
    """
    无限背包问题：每种物品可以选无限次

    状态转移方程：f(i,v) = max{f(i-1,v), f(i,v-a_i)+c_i}

    实现原理：
    - 使用一维DP数组，dp[v]表示容量v下的最大价值
    - 正序更新（从小到大遍历容量）：
      * 确保dp[v-a_i]已经包含当前物品的信息
      * 允许同一物品被重复选择
    - 时间复杂度：O(n·V)
    - 空间复杂度：O(V)
    """
    if not values or not weights or capacity <= 0:
        return 0

    n = len(values)
    dp = [0] * (capacity + 1)  # dp[v] = f(i,v) 在迭代过程中动态变化

    for i in range(n):
        # 正序更新：从小到大遍历容量
        # 当计算dp[w]时，dp[w-weights[i]]已经被更新为包含当前物品的状态
        for w in range(weights[i], capacity + 1):
            dp[w] = max(dp[w], dp[w - weights[i]] + values[i])

    return dp[capacity]
```
== 0/1背包问题

```python
def zero_one_knapsack(values: List[int], weights: List[int], capacity: int) -> int:
    """
    状态转移方程：f(i,v) = max{f(i-1,v), f(i-1,v-a_i)+c_i}

    实现原理：
    - 使用一维DP数组，dp[v]表示容量v下的最大价值
    - 逆序更新（从大到小遍历容量）：
      * 确保dp[v-a_i]仍然是上一轮的状态（f(i-1,v-a_i)）
      * 防止同一物品被重复选择
    - 时间复杂度：O(n·V)
    - 空间复杂度：O(V)
    """
    if not values or not weights or capacity <= 0:
        return 0

    n = len(values)
    dp = [0] * (capacity + 1)  # dp[v] = f(i-1,v) 在迭代开始前

    for i in range(n):
        # 逆序更新：从大到小遍历容量
        # 当计算dp[w]时，dp[w-weights[i]]尚未被当前轮更新，仍为f(i-1,w-weights[i])
        for w in range(capacity, weights[i] - 1, -1):
            dp[w] = max(dp[w], dp[w - weights[i]] + values[i])

    return dp[capacity]

```

== 有限背包问题

```python
def bounded_knapsack(values: List[int], weights: List[int], counts: List[int], capacity: int) -> int:
   """
   有限背包问题：每种物品最多选p_i件

   实现原理：
   - 二进制优化：将p_i个物品拆分成O(log p_i)个"捆绑包"
     * 任何0≤j≤p_i都可以由这些捆绑包组合而成
     * 例如：p_i=13拆分为1,2,4,6四个捆绑包
   - 每个捆绑包视为0/1物品，应用逆序更新
   - 当p_min→∞时，解收敛到无限背包问题的解
   - 时间复杂度：O(n·V·log p_max)
   - 空间复杂度：O(V)
   """
   if not values or not weights or not counts or capacity <= 0:
       return 0

   n = len(values)
   dp = [0] * (capacity + 1)  # dp[v] = f(i-1,v) 在迭代开始前

   for i in range(n):
       if counts[i] <= 0:
           continue

       # 二进制拆分：将counts[i]个物品拆分成log(counts[i])个捆绑包
       rest = counts[i]
       k = 1  # 2的幂次：1,2,4,8,...

       while rest > 0:
           take = min(k, rest)  # 当前捆绑包的物品数量

           # 计算捆绑包的总重量和总价值
           bundle_weight = take * weights[i]
           bundle_value = take * values[i]

           # 对每个捆绑包应用0/1背包的逆序更新
           # 确保每个捆绑包只被选择一次
           for w in range(capacity, bundle_weight - 1, -1):
               dp[w] = max(dp[w], dp[w - bundle_weight] + bundle_value)

           # 更新剩余数量和下一个2的幂次
           rest -= take
           k <<= 1  # k *= 2

   return dp[capacity]
```

*/
