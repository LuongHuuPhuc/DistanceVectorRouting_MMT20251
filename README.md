# MÔ PHỎNG DISTANCE VECTOR ROUTING
## 1. Giới thiệu Distance Vector Routing (DVR)
- **Distance Vector Routing** là một thuật toán định tuyến trong đó mỗi Router không có cái nhìn toàn cục về mạng, mà chỉ dựa vào thông tin cục bộ từ các Router láng giềng
- Là thuyết toán định tuyến trong đó, mỗi router chi biết:
    - Chi phí từ nó đến các Router láng giềng trực tiếp
    - Bảng định tuyến (distance vector) của láng giềng 
- Router định kỳ trao đổi **vector khoảng cách** với láng giềng để cập nhật bảng định tuyến 
- Dựa trên công thức **Bellman-Ford**: 

$$ D_x(y) = \min_{v \in \text{Neighbors}(x)} \{ c(x, v) + D_v(y) \} $$

- Trong đó:
    - $D_x(y)$ là **Metric (tổng cost)** mà Router x tin là chi phí tốt nhất để đi tới đích y (theo nhận thức của x)
    - $c(x, v)$ là cost vật lý từ Router x đến Router láng giềng v (niềm tin)
    - $D_v(y)$ là **Metric (tổng cost)** mà Router v quảng bá tới đích y 

## 2. Mô hình mô phỏng 
### 2.1 Thành phần mô phỏng
| Thành phần            | Ý nghĩa             |
| --------------------- | ------------------- |
| Node                  | Router              |
| Link                  | Kết nối giữa router |
| Cost                  | Trọng số link       |
| Distance Vector Table | Bảng định tuyến     |
| Iteration             | Một chu kỳ cập nhật |

### 2.2 Giả định trong mô phỏng 
- Mạng hoạt động theo mô hình tĩnh trong từng iteration 
- Không xét delay, packet loss
- Các Router cập nhật bảng định tuyến đồng bộ theo vòng lặp (`DV = DV_new`)
- Topology có thể thay đổi do link failure ngẫu nhiên
- Theo lý thuyết, **Metric** được tính bằng tổng **chi phí (cost)** các link trên đường đi, và hoàn toàn độc lập với vòng lặp cập nhật của thuật toán
    - Tuy nhiên trong mô phỏng này, **Metric** lại là tổng trọng số liên kết, không nhất thiết tương ứng với số **hop** hay đơn vị vật lý cụ thể (mỗi link có độ đắt rẻ khác nhau)
- **Cost** trong mô phỏng này không phải **hop-count** mà là trọng số (link metric) tổng quát - link có giá trị tùy ý, nhằm quan sát rõ hơn **Count-to-Infinity**
    - Vì thế nên **Count-to-Infinity** vẫn xảy ra nhưng không tăng đều 1-2-3-4... mà tăng theo tổng trọng số và đồ thị có thể tăng lên rất nhanh (hàng trăm, hàng nghìn lần) 
- Ký hiệu trong mô phỏng:
    - `DV(u, v)`: là **Metric** mà Router u quảng bá đến láng giềng v của nó
    - `cost(u, v)`: là **cost** vật lý của link giữa Router u đến Router v

## 3. Thành phần nâng cao 
### 3.1 Count-to-Inifinity Problem (Lỗi kinh điển của Distance-Vector)
- **Count-to-Infinity** xảy ra khi: 
    - Một link bị đứt
    - Các Router không biết ngay lập tức
    - Các Router tiếp tục cập nhật bảng định tuyến dựa trên thông tin lỗi thời từ láng giềng 
- Hậu quả là chúng cập nhật sai lẫn nhau, làm cho cost tăng dần, tăng dần đến vô hạn 
- Ví dụ trực quan: 
    - Giả sử có 3 Router: 
```css
A —— B —— C
```
| Link | Cost |
| ---- | ---- |
| A–B  | 1    |
| B–C  | 1    |

- Ban đầu: 
    - A → C = 2 (qua B)
    - B → C = 1
- Sự cố xảy ra:
    - Link B-C bị đứt 
    - Chỉ node B biết link bị đứt, nhưng A vẫn nghĩ "Qua B, tôi đi đến C mất 2 cost" và quảng bá nó cho node xung quanh
    - Khi link B-C bị đứt, node B lại nghĩ:"À, A đi được đến C, vậy thì mình đi qua A" ($B→C=1+2=3$)
    - Tiếp tục B lại quảng bá thông tin lỗi thời rằng "tôi đến C mất 3 cost" (`Cost(B→C) = 3`)
    - B lại quảng bá lại cho A và A lại nghĩ: $A→C=1+3=4$
    - Cứ thế $2 → 3 → 4 → 5 → 6 → ... → ∞$
- Hiên tượng này được quan sát khi một liên kết bị hỏng và các router khác tiếp tục cập nhật bảng định tuyến dựa trên thông tin lỗi thời từ láng giềng
- Mô phỏng MATLAB:
```matlab
cost(2,3) = Inf;
cost(3,2) = Inf;
```
- **Count-to-Infinity** xảy ra khi đồng thời 3 điều kiện đúng: 

| Điều kiện                         |
| --------------------------------- 
| Router cập nhật **bất đồng bộ**   | 
| Router **chấp nhận cost tăng**    |
| Router **tin thông tin lỗi thời** |
- Chỉ xảy ra khi Router không biết sự thật mà chỉ mù quáng tin lời hàng xóm

### 3.2 Link Failure Simulation (Mô phỏng đứt link)
- Ý nghĩa mô phỏng: 
    - Cáp bị đứt
    - Router chết
    - Kết nối không còn tồn tại
- Mô phỏng này để kiểm tra cho lỗi **Count-to-Infinity** và quan sát số vòng hội tụ lại
- Trong bài mô phỏng, các liên kết và Router có thể bị lỗi ngẫu nhiên nhằm phản ánh điều kiện hoạt động thực thế của mạng
- Kết quả cho thấy thuật toán Distance Vector cần cơ chế chống vòng lặp để đảm bảo hội tụ ổn định trong môi trường không tin cậy

### 3.3 Split Horizon & Poisoned Reverse 
#### Split Horizon 
- Split Horizon là cơ chế trong đó 1 Router không quảng bá một route ngược lại chính Router đã cung cấp Route đó
- Mục tiêu: Chặn vòng lặplặp, hạn chế Count-to-Infinity 
- Ví dụ: nếu A học được đường tới C thông qua B -> A không nói lại với B rằng A đã có đường tới C 

#### Poisoned Reverse 
- Là phiên bản mạnh hơn của **Split Horizon**
- Thay vì không quảng bá route: 
    - Router vẫn quảng bá route đó 
    - Nhưng với Cost vô hạn 
- Điều này đảm bảo rằng:
    - Router láng giềng chắc chắn không sử dụng Route đó 
    - Hiện tượng vòng lặp được loại bỏ gần như hoàn toàn 

### 3.4 Mạng hội tụ 
- Mạng được xem là hội tụ khi các bảng Distance Vector của tất cả router không còn thay đổi sau một vòng cập nhật.
- Hay có nghĩa là toàn bộ bảng định tuyến không thay đổi, không còn Router nào có thể cải thiện (giảm) cost đến bất kỳ đích nào nữa 
- Điều này tương đương với việc không tồn tại đường đi nào có chi phí nhỏ hơn có thể được khám phá thêm.
- Công thức **Bellman-Ford** cho mạng hội tụ khi:

$$ DV^{(k + 1)} = DV\^{(k)}$$

- Với mọi Router $x$ và mọi đích $y$ hội tụ khi:

$$D_x^{(k+1)}(y) = D_x^{(k)}(y)$$

## 4. Kiến trúc file MATLAB 
```css
DV_Routing_Simulation/
│
├── main.m                     % Chạy mô phỏng
├── init_topology.m            % Khởi tạo mạng
├── distance_vector_step.m     % 1 vòng cập nhật DV
├── check_convergence.m        % Kiểm tra hội tụ
├── print_routing_table.m      % In bảng định tuyến
└── README.txt                 % Giải thích lý thuyết
```
## 5. Đầu vào và đầu ra của mô phỏng 
### 5.1 Input
- Số Router (`numNodes`)
- Topology mạng (danh sách các liên kết) 
- Xác suất link failure 
- Bật/tắt Split Horizon và Poisoned Reverse 
### 5.2 Output 
- Bảng định tuyến của mỗi Router theo từng Iteration 
- Topology mạng trước và sau link failure 
- Đường đi ngắn nhất giữa các Router
- Đồ thị quá trình hội tụ của thuật toán
- Trong mô phỏng, các sự cố liên kết được tạo ra ngẫu nhiên tại nhiều thời điểm khác nhau. 
    - Sau mỗi lần link failure, topology mạng được lưu lại để phục vụ phân tích. 
    - Điều này cho phép quan sát sự thay đổi dần dần của cấu trúc mạng cũng như ảnh hưởng của từng sự cố đến quá trình hội tụ của thuật toán Distance Vector.
## 6. Nhân xét
- Việc cập nhật bảng định tuyến sau mỗi vòng lặp là bắt buộc cho thuật toán DVR (trong thực tế). Đây là điều kiện bắt buộc để mạng có thể hội tụ. 
- Mỗi Router cập nhật bảng định tuyến của chính nó, dựa trên thông tin mà nó nhận được trong vòng đó
    + Router KHÔNG nhìn thấy Topology của toàn mạng 
    + Router KHÔNG biết link xa bị đứt 
    + Router chỉ tin những gì hàng xóm quảng bá 
- Qua các vòng lặp thì thông tin bảng định tuyến vẫn được cập nhật nhưng lại cập nhật thông tin SAI của hàng xóm
-  **Count-to-Infinity** chính là hậu quả của việc "tin nhầm thông tin cũ" đó.
- Nếu không thực hiện bước cập nhật này, các Route sẽ tiếp tục sử dụng thông tin định tuyến cũ, dẫn đến việc lặp lại các thông tin sai lệch và càng dễ gây ra **Count-to-Infinity**
- Tuy nhiên bản thân việc cập nhật **Distance Vector** không phải là cơ chế chống **Count-to-Infinity**.
