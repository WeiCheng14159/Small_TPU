def float_to_hex(data, int_bit, point_bit, merge):
    hex_map = ['0', '1', '2', '3', '4', '5', '6',
               '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']

    int_part = data - data % 1  # 整數部分
    point_part = data % 1  # 小數部分
    bit_num = int_bit + point_bit  # 總bit數
    bit_res = bit_num % 4  # 處理到最後剩餘bit數
    before_merge = ['' for data_num in range(len(data))]  # 合併前結果

    for data_index in range(len(data)):  # 將signed轉換成unsigned
        if int_part[data_index] < 0:
            int_part[data_index] += (2 ** int_bit)

    unsigned_fixed = int_part + point_part  # unsigned fixed point
    for pow in range(int_bit, -point_bit - 1, -4):
        if pow != int_bit:
            unsigned_fixed = unsigned_fixed * (2 ** -pow)
            # print("ASDFADSFADSF", len(unsigned_fixed))
            for data_index in range(len(unsigned_fixed)):
                before_merge[data_index] = before_merge[data_index] + \
                    hex_map[int(unsigned_fixed[data_index])]
            unsigned_fixed = (unsigned_fixed % 1) * (2 ** pow)
    if bit_res != 0:  # 剩餘bit
        unsigned_fixed = (unsigned_fixed * (2 ** point_bit) -
                          (unsigned_fixed * (2 ** point_bit) % 1)) * (2 ** (4 - bit_res))
        for data_index in range(len(unsigned_fixed)):
            before_merge[data_index] = before_merge[data_index] + \
                hex_map[int(unsigned_fixed[data_index])]

    # print(before_merge)

    if len(data) % merge != 0:
        print('無法整除')
    else:
        result = ['' for data_num in range(int(len(data) / merge))]  # Merge後結果

        head_index = 0  # 開頭位置
        now_index = 0  # 儲存在result的位置

        while now_index != len(result):
            for i in range(head_index, head_index + merge):
                result[now_index] += before_merge[i]
            head_index += merge
            now_index += 1

        return result
